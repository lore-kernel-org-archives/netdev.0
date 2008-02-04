From: adi@drcomp.erfurt.thur.de (Adrian Knoth)
Subject: No IPv6 addresses after resume (No buffer space available)
Date: Mon, 4 Feb 2008 14:16:15 +0100
Message-ID: <20080204131615.GT11368@ltw.loris.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ltw.loris.tv ([85.14.220.160]:36164 "EHLO ltw.loris.tv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758762AbYBDNuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 08:50:14 -0500
Received: from localhost (ltw.loris.tv [127.0.0.1])
	by ltw.loris.tv (Postfix) with ESMTP id 0A80E500116
	for <netdev@vger.kernel.org>; Mon,  4 Feb 2008 14:16:22 +0100 (CET)
Received: from ltw.loris.tv ([127.0.0.1])
	by localhost (ltw [127.0.0.1]) (amavisd-new, port 10024) with LMTP
	id 22747-04 for <netdev@vger.kernel.org>;
	Mon, 4 Feb 2008 14:16:15 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I use suspend-to-RAM on my HP nx6325 laptop. I have three main
locations:

   - place A: IPv4 + IPv6
   - place B: IPv4 + IPv6
   - place C: IPv4 only

Suspending in place A and travelling to place B is no problem, I'm
always getting the local RAs, the right addresses a.s.o.

But once I've been in place C (no IPv6 there at this site), resuming in
A or B doesn't give me IPv6, I don't even get a link local address. Only
the loopback interface is left functional:

adi@chopin:~$ ls /proc/sys/net/ipv6/conf/
all  default  eth1  lo

chopin:/home/adi# ip -6 a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 
    inet6 ::1/128 scope host 
           valid_lft forever preferred_lft forever

eth0 is missing, also in /proc/sys/net/ipv6/conf (as shown above).

When I try to assign my link local address, it fails:

chopin:/home/adi# ip -6 a a fe80::0217:a4ff:fed7:a23e/64 scope link dev eth0
RTNETLINK answers: No buffer space available

It doesn't help to cycle the interface down and up. My current
workaround is to unload the NIC driver (tg3) and modprobe it again: 

[rmmod tg3 ; modprobe tg3]
chopin:/home/adi# ip -6 a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
15: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 fe80::217:a4ff:fed7:a23e/64 scope link 
       valid_lft forever preferred_lft forever

[and a few moments later]
chopin:/home/adi# ip -6 a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
15: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:638:906:2:217:a4ff:fed7:a23e/64 scope global dynamic 
       valid_lft 2591987sec preferred_lft 604787sec
    inet6 fe80::217:a4ff:fed7:a23e/64 scope link 
       valid_lft forever preferred_lft forever


Hope you can identify the culprit.


TIA,

Cheerio


-- 
mail: adi@thur.de  	http://adi.thur.de	PGP/GPG: key via keyserver
