From: eric@certus.bz
Subject: ping6
Date: Mon, 18 Jul 2011 14:23:33 -0600
Message-ID: <fa4b41e8992b983d77dc2b57c72431e7.squirrel@charon>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.quartz.synacor.com ([205.169.121.111]:50122 "EHLO
	smtp.q.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803Ab1GRUbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 16:31:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I've found what I think is a bug in the ping6 tool. Without the -n option,
it puts the hostname inside the parenthesis instead of the resolved ip
address as demonstrated below:

ericat@hydra:~/iputils-s20101006$ ping6 ipv6.he.net
PING ipv6.he.net(ipv6.he.net) 56 data bytes
64 bytes from ipv6.he.net: icmp_seq=1 ttl=58 time=186 ms

I expect output like this:

ericat@hydra:~/iputils-s20101006$ sudo ./ping6 ipv6.he.net
Password:
PING ipv6.he.net(2001:470:0:64::2) 56 data bytes
64 bytes from ipv6.he.net: icmp_seq=1 ttl=58 time=187 ms

Here's a very simple patch to ping6.c for proper behaviour:

ericat@hydra:~/iputils-s20101006$ diff ping6.c.orig ping6.c
979c979
<       printf("PING %s(%s) ", hostname, pr_addr(&whereto.sin6_addr));
---
>       printf("PING %s(%s) ", hostname, pr_addr_n(&whereto.sin6_addr));

Cheers,
Eric Atkin


