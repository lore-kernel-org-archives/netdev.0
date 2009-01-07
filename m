From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] hdlc: fix compile problem
Date: Wed, 7 Jan 2009 15:28:58 -0800
Message-ID: <20090107152858.6fb8ac5d@extreme>
References: <20090107141343.3e256119@extreme>
	<m3d4eyvh28.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33106 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754621AbZAGX3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 18:29:00 -0500
In-Reply-To: <m3d4eyvh28.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 Jan 2009 00:21:03 +0100
Krzysztof Halasa <khc@pm.waw.pl> wrote:

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
> > Fix build problem with hdlc driver. hdlc_null_ops was being referenced
> > before it was defined!
> 
> :-)
> 
> Unfortunately I can't see it, which tree is it?
> 
> 
> In David's and Linus' trees it appears twice, it seem to be entirely
> correct and btw you are the author :-)
> ... and it compiled here 100 times or so :-)
> 
> static const struct header_ops hdlc_null_ops;
>                                ^^^^^^^^^^^^^
> static void hdlc_setup_dev(struct net_device *dev)
> {
>         /* Re-init all variables changed by HDLC protocol drivers,
>          * including ether_setup() called from hdlc_raw_eth.c.
>          */
>         dev->get_stats           = hdlc_get_stats;
>         dev->flags               = IFF_POINTOPOINT | IFF_NOARP;
>         dev->mtu                 = HDLC_MAX_MTU;
>         dev->type                = ARPHRD_RAWHDLC;
>         dev->hard_header_len     = 16;
>         dev->addr_len            = 0;
>         dev->header_ops          = &hdlc_null_ops;
>                                   ^^^^^^^^^^^^^^^^
>         dev->change_mtu          = hdlc_change_mtu;
> }

It was introduced (by me) in previous patch. Since that isn't applied yet,
I'll go back and fix.
