From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/3] ipv6: use newly introduced __ipv6_addr_needs_scope_id and ipv6_iface_scope_id
Date: Wed, 13 Feb 2013 18:21:48 +0100
Message-ID: <20130213172148.GA24534@order.stressinduktion.org>
References: <20130212221634.GA7212@order.stressinduktion.org> <20130213001357.GB1096@order.stressinduktion.org> <511AFF9A.8040506@hp.com> <511BC3B3.3070405@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33478 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759964Ab3BMRVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 12:21:49 -0500
Content-Disposition: inline
In-Reply-To: <511BC3B3.3070405@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2013 at 01:47:47AM +0900, YOSHIFUJI Hideaki wrote:
> If you have several address checks around, please use ipv6_addr_type()
> (or __ipv6_addr_type()).  Above "direct" checks should be used only for
> single-shot test.  But well, I have to agree that ipv6_addr_type and
> friends is becoming complex.  In mid-term, I would like to take look
> at it.  I might think of having addr_type for src/dst in skb->cb
> after all.

Yes, I had no plan to duplicate addrconf_core tests. I just thought about

a) not using addr_types at all in the new helper functions
b) use something like

union ipv6_addr_type {
	struct {
		__u16 scope;
		__u16 addr_type;
	};
	__u32 type_and_scope;
}

and explicitly use this in __ipv6_addr_type (this function does not seam to be
used as often as ipv6_addr_type).
