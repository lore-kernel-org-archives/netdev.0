From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/23] [PATCH] [XFRM] STATE: Add source address list.
Date: Tue, 01 Aug 2006 16:57:28 -0700 (PDT)
Message-ID: <20060801.165728.18308673.davem@davemloft.net>
References: <11541654121350-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16825
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750833AbWHAX53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 19:57:29 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <11541654121350-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 29 Jul 2006 18:30:12 +0900

> @@ -263,6 +263,7 @@ struct xfrm_usersa_id {
>  	__u32				spi;
>  	__u16				family;
>  	__u8				proto;
> +	xfrm_address_t			saddr;
>  };
>  
>  struct xfrm_aevent_id {

This is a userspace exported structure, therefore you cannot
make changes to it like this, it will break the userland API.

If you need to provide the source address, you need to pass it in via
a new xfrm netlink attribute or use an existing data structure member
which records the source address (if any such thing does exist).
