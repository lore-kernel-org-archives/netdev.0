From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header handling
 routines
Date: Thu, 6 Mar 2014 11:11:39 +0100
Message-ID: <20140306111139.2b7b6b8b@zoidberg>
References: <1393943688-24221-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<20140304.170050.2058599034902221847.davem@davemloft.net>
	<7c9810ea21990e7e239b101f548818f7.squirrel@webmail.itwm.fhg.de>
	<20140305.193913.470467212827707623.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:36808 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaCFKLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 05:11:55 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s26ABqhn025800
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 6 Mar 2014 11:11:53 +0100
In-Reply-To: <20140305.193913.470467212827707623.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Mar 2014 19:39:13 -0500 (EST)
David Miller <davem@redhat.com> wrote:

> This is how we handle some fields of struct iphdr, and it's fine with
> me.

Wonderful, this will unclutter everything that concerns itself with
some degree of header handling.

> Be sure to use __LITTLE_ENDIAN_BITFIELD and __BIG_ENDIAN_BITFIELD for
> your CPP checks.

I looked at struct iphdr now that you mentioned it, and i was a little
surprised to see that this header is often pointer-cast from an
skb_network_header. As far as I can see, declaring all subfields (say)
u16 in the bitfield endianness order when the entire bitfield is a u16
in the header will result in correct behaviour for cast/memcpy. Is this
correct? If not, I'll write out explicit operations for each bitfield
member.
