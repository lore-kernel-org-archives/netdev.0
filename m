From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iputils: ping by mark
Date: Sat, 17 Oct 2009 19:34:45 -0400
Message-ID: <1255822485.4815.15.camel@dogo.mojatatu.com>
References: <1255381558.5406.33.camel@dogo.mojatatu.com>
	 <7e84ed60910161405i2ce46053m9858b7f1c086e6b7@mail.gmail.com>
	 <1255782635.11213.7.camel@dogo.mojatatu.com>
	 <55a4f86e0910171154v460146a8m1360fac71f9ddac8@mail.gmail.com>
	 <1255820692.4815.2.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rob.Townley@gmail.com, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:38704 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbZJQXhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2009 19:37:46 -0400
Received: by qyk32 with SMTP id 32so2225760qyk.4
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2009 16:37:50 -0700 (PDT)
In-Reply-To: <1255820692.4815.2.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-10-17 at 19:04 -0400, jamal wrote:

> This patch has worked fine in
> 2.6.31 and pre-31 where i tested. 

Ok, just to be sure - here's a simple test i just did on my laptop...

------
hadi@dogo:~$ uname -a
Linux dogo 2.6.31-rc7-00001-g6da17c5-dirty #7 PREEMPT Thu Oct 15
16:35:13 EDT 2009 i686 GNU/Linux
hadi@dogo:~$ ip a ls dev eth0
11: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UNKNOWN qlen 1000
    link/ether 00:0b:97:97:4d:6a brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.31/24 brd 10.0.0.255 scope global eth0
    inet 10.0.0.2/32 scope global eth0
    inet6 fe80::20b:97ff:fe97:4d6a/64 scope link 
       valid_lft forever preferred_lft forever
hadi@dogo:~$ ip ru ls
0:	from all lookup local 
15:	from all fwmark 0xf lookup 15 
16:	from all fwmark 0x10 lookup 16 
32766:	from all lookup main 
32767:	from all lookup default 

hadi@dogo:~$ ip r ls table 15
208.67.217.231 via 10.0.0.1 dev eth0  src 10.0.0.31 
hadi@dogo:~$ ip r ls table 16
208.67.217.231 via 10.0.0.1 dev eth0  src 10.0.0.2 
hadi@dogo:~$ 

One ping with -m 15 -c1 to 208.67.217.231, tcpdump:
19:22:09.467555 IP 10.0.0.31 > 208.67.217.231: ICMP echo request, id
34328, seq 1, length 64
19:22:09.535429 IP 208.67.217.231 > 10.0.0.31: ICMP echo reply, id
34328, seq 1, length 64

repeat ping with -m 16 and watch tcpdump
19:23:19.731592 IP 10.0.0.2 > 208.67.217.231: ICMP echo request, id
50712, seq 1, length 64
19:23:19.790672 IP 208.67.217.231 > 10.0.0.2: ICMP echo reply, id 50712,
seq 1, length 64

------


I have also tried it with udp (hacked netcat) and i dont see any problem
either

What did i miss?

cheers,
jamal

