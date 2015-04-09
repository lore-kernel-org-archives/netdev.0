From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Thu, 09 Apr 2015 03:01:32 -0700
Message-ID: <1428573692.25985.248.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr>
	 <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr>
	 <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr>
	 <1428571471.25985.246.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:32911 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932657AbbDIKBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 06:01:35 -0400
Received: by iebmp1 with SMTP id mp1so96471120ieb.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 03:01:34 -0700 (PDT)
In-Reply-To: <1428571471.25985.246.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-09 at 02:24 -0700, Eric Dumazet wrote:

> 
> Thanks for providing these scripts, but they do not work on my host
> running latest net-next
> 
> Basic IP routing seems not properly enabled, as even ping does not work
> to reach 10.10.23.23
> 
> ip netns exec vclient /bin/bash
> ping 10.10.23.23
> <no frame is sent>
> 

Same problem if I run pristine 3.19

lpaa23:~/t# ip netns exec vclient /bin/bash
lpaa23:~/t# ip ro get 10.10.23.23
10.10.23.23 via 10.10.40.129 dev veth0  src 10.10.40.1 
    cache 
lpaa23:~/t# nstat
#kernel
lpaa23:~/t# ping 10.10.23.23
PING 10.10.23.23 (10.10.23.23) 56(84) bytes of data.
^C
--- 10.10.23.23 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 999ms

lpaa23:~/t# nstat
#kernel
IcmpOutErrors                   2                  0.0
IcmpOutEchoReps                 2                  0.0
IcmpMsgOutType8                 2                  0.0

lpaa23:~/t# grep . `find /proc/sys/net/ipv4 -name forwarding`
/proc/sys/net/ipv4/conf/all/forwarding:1
/proc/sys/net/ipv4/conf/default/forwarding:1
/proc/sys/net/ipv4/conf/gre0/forwarding:1
/proc/sys/net/ipv4/conf/gretap0/forwarding:1
/proc/sys/net/ipv4/conf/lo/forwarding:1
/proc/sys/net/ipv4/conf/sit0/forwarding:1
/proc/sys/net/ipv4/conf/veth0/forwarding:1
