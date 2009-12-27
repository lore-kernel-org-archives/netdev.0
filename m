From: Jeremy Jackson <jerj@coplanar.net>
Subject: Re: querying TOS/DSCP at accept() time?
Date: Sun, 27 Dec 2009 11:05:05 -0500
Message-ID: <1261929905.8193.24.camel@ragnarok>
References: <1261925852.8193.9.camel@ragnarok>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.coplanar.net ([70.47.139.2]:59181 "EHLO
	titan.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbZL0QFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2009 11:05:15 -0500
Received: from [70.47.139.174] (ragnarok.coplanar.net [70.47.139.174] (may be forged))
	(authenticated bits=0)
	by titan.coplanar.net (8.14.2/8.14.2/Debian-2build1) with ESMTP id nBRG5DOg029759
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 27 Dec 2009 11:05:14 -0500
In-Reply-To: <1261925852.8193.9.camel@ragnarok>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems this question was asked before in 2001:

http://www.squid-cache.org/mail-archive/squid-dev/200103/0035.html

http://lkml.indiana.edu/hypermail/linux/kernel/0103.0/1211.html

And apparently Squid developers made a kernel patch

http://zph.bratcheda.org/tos_marking_with_tos_preserving.htm
http://zph.bratcheda.org/

It seems like this is generally useful to a number of applications,
perhaps it should be included in mainstream kernel?

I see there's a structure member added, which will likely be frowned
upon, but perhaps it could be reworked to use the existing TOS byte
captured 

net/ipv4/tcp_ipv4.c:1645
     TCP_SKB_CB(skb)->flags   = iph->tos;

Cheers,

Jeremy

The kernel patch adds 
On Sun, 2009-12-27 at 09:57 -0500, Jeremy Jackson wrote:
> I would like to allow clients connecting to webserver to choose TOS/DSCP
> value they want in reply packets, based on TOS setting received by
> webserver in initial SYN-SYN/ACK-ACK exchange.  Linux samples the TOS
> byte of the ACK that moves the state to CONNECTED, presumably to use for
> later ECN processing, but I cannot find a way to get this from
> userspace.
> 
> net/ipv4/tcp_ipv4.c:1645
>     TCP_SKB_CB(skb)->flags   = iph->tos;
> 
> 
> Am I missing something in getsockopt(TCP_INFO perhaps?) or accept(), or
> is this currently not possible?
> 
> 
> 


-- 
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net

