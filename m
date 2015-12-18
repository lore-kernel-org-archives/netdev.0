From: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Subject: Re: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc -d class show dev <device_name> ' command
Date: Fri, 18 Dec 2015 19:39:25 +0300
Message-ID: <1313271450456765@web7g.yandex.ru>
References: <5917221449918579@web5j.yandex.ru>
	 <20151216161558.265296c7@redhat.com> <20151216160400.GJ6555@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Phil Sutter <phil@nwl.cc>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward10p.cmail.yandex.net ([87.250.241.195]:58638 "EHLO
	forward10p.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751019AbbLRQqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 11:46:50 -0500
In-Reply-To: <20151216160400.GJ6555@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil,

> Dmitrii, did iproute2 without your change even print the overhead as set
> by you before? Looking at the code, I'd assume not.

Tried building iproute2 (as of tag 4.2) and using the upstream linux kernel (also tag 4.2 - 64291f7db5bd8150a74ad2036f1037e6a0428df2):

~/src/iproute2/tc$ uname -r
4.2.0-040200-generic

~/src/iproute2/tc$ grep -inP 'htb' /boot/config-4.2.0-040200-generic 
1331:CONFIG_NET_SCH_HTB=m

~/src/iproute2/tc$ lsmod | grep htb
sch_htb                24576  1

~/src/iproute2/tc$ ./tc -d class show dev eth0

~/src/iproute2/tc$ sudo ./tc qdisc add dev eth0 root handle 1: htb default 12

~/src/iproute2/tc$ sudo ./tc class add dev eth0 parent 1: classid 1:1 htb rate 100kbps ceil 100kbps mpu 256 overhead 64

~/src/iproute2/tc$ tc -d class show dev eth0
class htb 1:1 root prio 0 quantum 10000 rate 800Kbit overhead 64 ceil 800Kbit linklayer ethernet burst 1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 0

~/src/iproute2/tc$ lsmod | grep htb
sch_htb                24576  1

So it looks like the overhead is being set correctly, but the mpu is not, even though the respective kernel module is loaded judging by what I see.

Regards,
Dmitrii Shcherbakov
