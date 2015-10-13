From: Li RongQing <roy.qing.li@gmail.com>
Subject: [bug report or not] ping6 will lost packets when ping6 lots of ipv6 address
Date: Tue, 13 Oct 2015 20:46:49 +0800
Message-ID: <CAJFZqHwASEOG-atD=yvygra=Ah5awF+9drmgGZm7L2OoGam0DQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:32902 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbJMMqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 08:46:50 -0400
Received: by qkas79 with SMTP id s79so6292941qka.0
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 05:46:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. in a machine, configure 3000 ipv6 address in one interface

for i in {1..3000}; do ip -6 addr add 4001:5013::$i/0 dev eth0; done


2. in other machine, ping6 the upper configured ipv6 address, then
lots of lost packets

ip -6 addr add 4001:5013::0/64 dev eth0
for i in {1..2000}; do ping6 -q -c1 4001:5013::$i; done;

3. increasing the gc thresh can handles these lost

sysctl -w  net.ipv6.neigh.default.gc_thresh1=2000
sysctl -w  net.ipv6.neigh.default.gc_thresh2=3000
sysctl -w  net.ipv6.neigh.default.gc_thresh3=4000
sysctl -w net.ipv6.route.gc_thresh=3000
sysctl -w net.ipv6.route.max_size =3000




-Roy
