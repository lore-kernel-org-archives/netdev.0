From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Sat, 30 Jan 2016 11:17:02 -0500
Message-ID: <20160130161702.GA11601@oracle.com>
References: <20160129180651.GA17127@oracle.com>
 <20160130024556.6227.51798.stgit@localhost.localdomain>
 <1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	davem@davemloft.net, alexander.duyck@gmail.com, tom@herbertland.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21244 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754413AbcA3QRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 11:17:14 -0500
Content-Disposition: inline
In-Reply-To: <1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/29/16 19:23), Eric Dumazet wrote:
> BTW, even a memcpy(&key_addrs->v4addrs, &iph->saddr, 8) could crash, as
> the compiler can certainly assume src and dst are 4 bytes aligned, and
> could use word accesses when inlining memcpy() even on Sparc.
> 
> Apparently the compiler used by Sowmini is gentle.

One more subtlety that I missed until now.. 

eth_get_headlen passes in flow_keys_buf_dissector (NOT flow_keys_dissector!)

So FLOW_DISSECTOR_KEY_IPV4_ADDRS is not set, and this helps to dodge
the unaligned iph->saddr access.

But as others have pointed out, much of this code is brittle
because it's accessing the data before the driver has had a chance
to align things. The page_offset initialization of NET_IP_ALIGN,
with all its weaknesses, at least matches (in principle) the prescription
used for the xmit path.

--Sowmini
