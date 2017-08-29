From: Joe Perches <joe@perches.com>
Subject: Re: [net-next] be2net: use shift instead of expensive divide
Date: Mon, 28 Aug 2017 20:44:02 -0700
Message-ID: <1503978242.2040.16.camel@perches.com>
References: <1503976719-3063-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0173.hostedemail.com ([216.40.44.173]:60962 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751232AbdH2DoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 23:44:05 -0400
In-Reply-To: <1503976719-3063-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-29 at 11:18 +0800, Zhang Shengju wrote:
> Replace shift instead of expensive divide.

This change is mostly pointless.
Any half-way decent compiler should produce the same object.
gcc emits the same object with the old code.

The AMAP_GET_BITS macro uses the "offsetof(struct, member) / 32"
style too.

> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
[]
> @@ -2455,7 +2455,7 @@ static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
>  
>  	/* For checking the valid bit it is Ok to use either definition as the
>  	 * valid bit is at the same position in both v0 and v1 Rx compl */
> -	if (compl->dw[offsetof(struct amap_eth_rx_compl_v1, valid) / 32] == 0)
> +	if (compl->dw[offsetof(struct amap_eth_rx_compl_v1, valid) >> 5] == 0)

etc...
