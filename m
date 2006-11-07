From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [XFRM/IPV6] fix next header offset in decode_session
Date: Tue, 07 Nov 2006 01:48:24 -0800 (PST)
Message-ID: <20061107.014824.50860428.yoshfuji@linux-ipv6.org>
References: <20061107093002.GA6576@palpatine.dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35595 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1752936AbWKGJpe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 04:45:34 -0500
To: jean-philippe.andriot@6WIND.com
In-Reply-To: <20061107093002.GA6576@palpatine.dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061107093002.GA6576@palpatine.dev.6wind.com> (at Tue, 7 Nov 2006 10:30:02 +0100), Jean-Philippe Andriot <jean-philippe.andriot@6WIND.com> says:

> The way to get the next protocol number of an IPv6 tunnel changes
> after introducing IP6CB, but I think we should go back to the
> previous version here.
:
>         struct ipv6_opt_hdr *exthdr;
> -       u8 nexthdr = skb->nh.raw[IP6CB(skb)->nhoff];
> +       u8 nexthdr = skb->nh.ipv6h->nexthdr;
>  
>         memset(fl, 0, sizeof(struct flowi));

I disagree.

If you do this, you refer to the first extension headers only.
We need to skip preceding extension headers using IP6CB(skb)->nhoff,
which holds the offset to the current nexthdr.

--yoshfuji
