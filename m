From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] hdlc: fix compile problem
Date: Thu, 08 Jan 2009 00:21:03 +0100
Message-ID: <m3d4eyvh28.fsf@maximus.localdomain>
References: <20090107141343.3e256119@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:32956 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754357AbZAGXVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 18:21:07 -0500
In-Reply-To: <20090107141343.3e256119@extreme> (Stephen Hemminger's message of "Wed\, 7 Jan 2009 14\:13\:43 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> Fix build problem with hdlc driver. hdlc_null_ops was being referenced
> before it was defined!

:-)

Unfortunately I can't see it, which tree is it?


In David's and Linus' trees it appears twice, it seem to be entirely
correct and btw you are the author :-)
... and it compiled here 100 times or so :-)

static const struct header_ops hdlc_null_ops;
                               ^^^^^^^^^^^^^
static void hdlc_setup_dev(struct net_device *dev)
{
        /* Re-init all variables changed by HDLC protocol drivers,
         * including ether_setup() called from hdlc_raw_eth.c.
         */
        dev->get_stats           = hdlc_get_stats;
        dev->flags               = IFF_POINTOPOINT | IFF_NOARP;
        dev->mtu                 = HDLC_MAX_MTU;
        dev->type                = ARPHRD_RAWHDLC;
        dev->hard_header_len     = 16;
        dev->addr_len            = 0;
        dev->header_ops          = &hdlc_null_ops;
                                  ^^^^^^^^^^^^^^^^
        dev->change_mtu          = hdlc_change_mtu;
}
-- 
Krzysztof Halasa
