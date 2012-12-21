From: Eric Dumazet <erdnetdev@gmail.com>
Subject: [RFC] IP_MAX_MTU value
Date: Thu, 20 Dec 2012 22:47:48 -0800
Message-ID: <1356072468.21834.4805.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:59572 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab2LUGrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 01:47:51 -0500
Received: by mail-pa0-f48.google.com with SMTP id fa1so2608767pad.35
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 22:47:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

We have the following definition in net/ipv4/route.c

#define IP_MAX_MTU   0xFFF0

This means that "netperf -t UDP_STREAM", using UDP messages of 65507
bytes, are fragmented on loopback interface (while its MTU is now 65536
and should allow those UDP messages being sent without fragments)

I guess Rick chose 65507 bytes in netperf because it was related to the
max IPv4 datagram length :

65507 + 28 = 65535

Changing IP_MAX_MTU from 0xFFF0 to 0x10000 seems safe [1], but I might
miss something really obvious ?

It might be because in old days we reserved 16 bytes for the ethernet
header, and we wanted to avoid kmalloc() round-up to kmalloc-131072
slab ?

If so, we certainly can limit skb->head to 32 or 64 KB and complete with
page fragments the remaining space.

Thanks

[1] performance increase is ~50% 
