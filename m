From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] net: add Fast Ethernet driver for PXA168.
Date: Tue, 10 Aug 2010 13:40:32 +0200
Message-ID: <20100810114032.GO8876@mail.wantstofly.org>
References: <EC64E4604C8024438259B683BB2514E1082B1CB1B0@SC-VEXCH1.marvell.com> <26AE03C2-9D1A-4E63-82E3-DD47BD451B70@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sachin Sanap <ssanap@marvell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Prabhanjan Sarnaik <sarnaik@marvell.com>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	Mark Brown <markb@marvell.com>
To: Philip Rakity <prakity@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:43870 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756686Ab0HJLke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 07:40:34 -0400
Content-Disposition: inline
In-Reply-To: <26AE03C2-9D1A-4E63-82E3-DD47BD451B70@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 06, 2010 at 08:44:02AM -0700, Philip Rakity wrote:

> You should change
> 
> >>> +		skb = dev_alloc_skb(MAX_PKT_SIZE + ETH_HW_IP_ALIGN);
> 
> >> 
> 
> to allocatie ADDITIONAL prepend space in the header.  If you are doing
> ethernet to 802.11 routing or bridging then the wireless driver will
> not have enough space in front of the header to prepend its headers
> without having to allocate additional space.

This seems like something that, should you want to handle it, should be
handled centrally (e.g. by conditionally increasing NET_SKB_PAD or so)
and not hardcoded into one specific driver only.
