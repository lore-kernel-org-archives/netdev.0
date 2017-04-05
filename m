From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH v2 00/13] ftgmac100: Rework batch 1 - Link & Interrupts
Date: Wed, 05 Apr 2017 15:53:15 +1000
Message-ID: <1491371595.4166.77.camel@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
         <2344b1ea-f8bc-7491-4662-b8a3e94fb94e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34943 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751979AbdDEFxd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 01:53:33 -0400
In-Reply-To: <2344b1ea-f8bc-7491-4662-b8a3e94fb94e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-04 at 21:21 -0700, Florian Fainelli wrote:
> 
> This looks pretty good to me, two minor things:
> 
> - most drivers keep track of the old status/duplex/pause/link variables
> instead of the current one which is already available within struct
> phy_device, any particular reason for not doing like the other drivers?

We don't necessarily have a phydev attached when using NC-SI, so it was
easier to have the core code path not have to go fishing for those
settings in different places based on whether we're using NC-SI or not.

> - the need to reset the HW during link changes is just ... well too bad

Yup but there's little choice. The HW wants it. I don't see any real
point in optimizing that path mind you. Losing a few packets around
a link change isn't going to hurt and it keeps the code a lot simpler
by having a single "re-init" path.

> With that:
> 
> > Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks !

I'll post batch 2 in the next couple of days which tackles the RX path.

Cheers,
Ben.
