From: Atis Elsts <atis@mikrotik.com>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening sockets, and for IPv4 multicast forwarding
Date: Wed, 14 Oct 2009 14:04:37 +0300
Message-ID: <200910141404.37882.atis@mikrotik.com>
References: <20091007.223928.34412707.davem@davemloft.net> <55a4f86e0910140250o45532dabr33707c025dfa25f9@mail.gmail.com> <20091014092743.GA13374@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Maciej =?utf-8?q?=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	panther@balabit.hu, eric.dumazet@gmail.com, brian.haley@hp.com
To: steve@chygwyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.196]:51430 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758569AbZJNLE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 07:04:26 -0400
In-Reply-To: <20091014092743.GA13374@fogou.chygwyn.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 October 2009 12:27:43 steve@chygwyn.com wrote:
>
> The mark is supposed to be a generic thing, not just for routing
> lookups, it can be used for classification, etc as well. 

In general, sounds like a good idea, but IMHO exactly this could be a problem.
skb->mark is already used for a lot of things. What if I am setting the mark 
by a firewall rule in prerouting chain, and matching it by a postrouting 
rule? If routing lookup was changing the mark, then my setup would break.

Perhaps one more field could be added dst_entry? The field would be filled 
from route's table (if "setmark" for that route was specified). The use of 
that field would be similar to tclassid (e.g matching in firewall), except 
that it would also be used in routing lookups, if set.

> I would 
> expect to see such a thing used for maybe specifying a VLAN or
> a reference to an MPLS label stack, or something similar too,
>
> Steve.


