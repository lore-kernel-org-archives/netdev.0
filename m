From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] IPv6: Use a 16 bit length field when
 computing a IPv6 UDP checksum
Date: Tue, 01 Mar 2016 16:35:44 -0500 (EST)
Message-ID: <20160301.163544.1175023538158578123.davem@davemloft.net>
References: <20160226025738.16760.41163.stgit@localhost.localdomain>
	<20160301.150902.257372984527759080.davem@davemloft.net>
	<CAKgT0Ue-OGtHy4=f7mYRxLntgj1rgGpyD2ZojvULY_7EXykhKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbcCAVfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 16:35:47 -0500
In-Reply-To: <CAKgT0Ue-OGtHy4=f7mYRxLntgj1rgGpyD2ZojvULY_7EXykhKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 1 Mar 2016 13:19:28 -0800

> I was wondering what your thoughts would be about widening the size of
> the length field that we pass into csum_tcpudp_magic from a 16 bit to
> a 24 or 32 bit value?  The general idea would be to shift tunnels over
> to uniformly using skb->len instead of a mix of 16 bit or 32 bit
> lengths.  My thought is it might add a bit of security since it would
> invalidate the outer header checksum for the case where length has
> exceeded 65535 resulting in uh->len field being invalid anyway.

Hmmm, but wait, what is uh->len supposed to be for an ipv6 jumbogram
anyways?

It just gets truncated and the the ipv6 header payload length field
trumps whatever is in the UDP header length field right?

If that's what happens then we should uniformly use the truncated
length for the pseudo-header calculations as you originally suggested.

How UDP jumbograms as supposed to be handled wrt. udp_hdr->len should
guide our implementation.
