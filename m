From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 22:25:57 +0300
Message-ID: <200808282225.57535.denys@visp.net.lb>
References: <20080827.201020.17601834.davem@davemloft.net> <200808281948.52608.denys@visp.net.lb> <48B6F4FE.6010308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Joe Malicki <jmalicki@metacarta.com>,
	David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	juhlenko@akamai.com, sammy@sammy.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:51138 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbYH1T12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 15:27:28 -0400
In-Reply-To: <48B6F4FE.6010308@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 August 2008, Eric Dumazet wrote:

> So... if using ping on your machine has direct an noticeable effect on cpu
> load, problem is elsewhere (if no ping is running, you dont have skb
> timestamping, but still getnstimeofday() is the top function in oprofile)

>
> 1) Do you have any netfilter rule using xt_time ?
>    (This module also calls __net_timestamp(skb))
No

>
> 2) You maybe have a bad program that do something expensive relative to
> kernel time services.
No, process list is very short, it is custom semi-embedded linux distro i 
made, so i know each process running there.  Here is process list (kernel 
processes/threads and running shell(busybox ash) removed) 

1 root     /bin/sh /init
 1119 root     init
 2451 root     /sbin/syslogd -R 80.83.17.2
 2453 root     /sbin/klogd
 3168 squid    /usr/sbin/zebra -d
 3175 squid    /usr/sbin/ripd -d
 3195 root     /usr/sbin/snmpd -c /config/snmpd.conf
 3208 root     udhcpd /config/udhcp.office.conf -S
 3550 root     /usr/sbin/sshd -b /etc/banner
 3566 root     /sbin/getty 38400 tty1
 3567 root     /sbin/getty 38400 tty2
 3570 root     /sbin/getty 38400 tty3
 4055 root     /usr/sbin/sshd -b /etc/banner

> Your setup is probably not common.
> You want a PersonnalComputer class machine acts as a SuperCiscoDevice(TM),
> while most PC machines dont use more than 10% of CPU power in average...
I dont think i am alone, and almost sure there is many guys trying to run 
linux as high-performance router. But most of them dont know about 
netdev@ :-)

Well, thats called "Increasing resources use efficiency and system 
productivity". It is never a shame to utilize resources more efficiently. 
Plus i am not using PC class machine. For example this one with HPET, is Sun 
Fire X4100, which costs us that time a lot of bucks, and mostly because it is 
reliable hardware (very good IPMI/remote kvm/... onboard, good cooling, 4 
e1000, dual power supply).

I can use also PC class, but i will face some issues, like building proper 
cooling system and maybe even it will not work well, cause some chips not 
designed for "heavy duty", and on load they will not be able to dissipate 
heat inside the chip and will be broked soon. But sometimes it is even worth 
to try.

And most important, many routers is already "soft"-routers. What is Cisco 
7206+NPE G1/G2? It is MIPS CPU with relatively large L2 cache. There is seems 
no ASIC for routing offloading.  Means Linux can do same or better job.
And means Vyatta can beat Cisco on this market, and be far away forward from 
Cisco soon. As result more jobs for opensource guys. Linux must enter "heavy 
duty" and critical jobs too, not only SOHO-class routers.

>
> Many existing programs depend on current SO_TIMESTAMP.
> We wont break them to solve a particular problem (yet to be demonstrated)
I think it wouldn't break. But sure we must be very careful and on my side i 
can test all possible scenarios i can implement.

Maybe even good idea to not change (for now) current  default behaviour, but 
to provide option for "high performance" systems then.

> kernel already provides nanosecond resolution :)
> Check SO_TIMESTAMPNS and SCM_TIMESTAMPNS
Maybe this function really must be "heavy" then.
