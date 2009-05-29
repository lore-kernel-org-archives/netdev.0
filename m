From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] netdev: bfin_mac: fix performance issue found by
 netperf
Date: Fri, 29 May 2009 02:05:54 -0700 (PDT)
Message-ID: <20090529.020554.107005632.davem@davemloft.net>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
	<1243404615-25879-4-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	michael.hennerich@analog.com, cooloney@kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38943
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757140AbZE2JFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 05:05:54 -0400
In-Reply-To: <1243404615-25879-4-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Wed, 27 May 2009 02:10:13 -0400

> @@ -606,86 +606,28 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
>  				struct net_device *dev)
>  {
>  	u16 *data;
> -
> +	u32 data_align = (u32)(skb->data) & 0x3;

A pointer is not castable directly to a u32 everywhere.  It can be
64-bits and in which case GCC will warn here.

I know this is a blackfin specific driver, but please write portable
code.

Use "unsigned long" or similar.

I'm not applying this as it is now.
