From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp6: fix UDP/IPv6 encap resubmit path
Date: Mon, 07 Mar 2016 15:23:52 -0500 (EST)
Message-ID: <20160307.152352.119878767057546985.davem@davemloft.net>
References: <1457131641-79311-1-git-send-email-wsommerfeld@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, johunt@akamai.com, bcrl@kvack.org,
	edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: wsommerfeld@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753103AbcCGUXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:23:55 -0500
In-Reply-To: <1457131641-79311-1-git-send-email-wsommerfeld@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Sommerfeld <wsommerfeld@google.com>
Date: Fri,  4 Mar 2016 14:47:21 -0800

> IPv4 interprets a negative return value from a protocol handler as a
> request to redispatch to a new protocol.  In contrast, IPv6 interprets a
> negative value as an error, and interprets a positive value as a request
> for redispatch.
> 
> UDP for IPv6 was unaware of this difference.  Change __udp6_lib_rcv() to
> return a positive value for redispatch.  Note that the socket's
> encap_rcv hook still needs to return a negative value to request
> dispatch, and in the case of IPv6 packets, adjust IP6CB(skb)->nhoff to
> identify the byte containing the next protocol.
> 
> Signed-off-by: Bill Sommerfeld <wsommerfeld@google.com>

Applied and queued up for -stable, thanks.
