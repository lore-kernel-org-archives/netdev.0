From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 05/13] ftgmac100: Cleanup speed/duplex tracking and fix
 duplex config
Date: Mon, 03 Apr 2017 07:27:22 +1000
Message-ID: <1491168442.26047.19.camel@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
         <20170402033523.9482-6-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36339 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750916AbdDBV1d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 17:27:33 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v32LRNpI029204
        for <netdev@vger.kernel.org>; Sun, 2 Apr 2017 16:27:27 -0500
In-Reply-To: <20170402033523.9482-6-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-02 at 13:35 +1000, Benjamin Herrenschmidt wrote:
> +       } else if (priv->cur_speed) {
> +               /* No link, just return. Leave the HW alone so it can
> +                * continue draining the tx ring.
> +                */
> +               netdev_info(netdev, "Link down\n");
>                 return;
> +       }
>  
> -       priv->old_speed = phydev->speed;
> +       priv->cur_speed = new_speed;
> +       priv->cur_duplex = phydev->duplex;

Finding my own bugs too ... the return above makes us fail
to update priv->cur_speed, thus the driver still thinks we
have a link. Not a huge deal but I'll fix too. (Caused by a
recent re-org in that code).

Cheers,
Ben.
