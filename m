From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: bcmgenet: Utilize correct struct device for all
 DMA operations
Date: Thu, 1 Dec 2016 09:26:04 -0800
Message-ID: <99ae5d99-23cb-7e48-6366-d0206b7f92cc@gmail.com>
References: <1480569350-43535-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
        opendmb@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34224 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932760AbcLAR0H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 12:26:07 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so5173905pgc.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 09:26:07 -0800 (PST)
In-Reply-To: <1480569350-43535-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2016 09:15 PM, Florian Fainelli wrote:
> __bcmgenet_tx_reclaim() is not using the struct device reference when
> doing its unmap operation, which made the DMA-API debugging warn about
> it. Fix this by always using &priv->pdev->dev throughout the driver,
> using an identical device reference for all map/unmap calls.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

There is another wrong struct device used by bcmgenet_free_rx_buffers
that I missed here (thanks Doug), let's fix it.
-- 
Florian
