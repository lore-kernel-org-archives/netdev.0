From: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Subject: Re: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc -d class show dev <device_name> ' command
Date: Wed, 16 Dec 2015 23:56:35 +0300
Message-ID: <930151450299395@web20m.yandex.ru>
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
Received: from forward20m.cmail.yandex.net ([5.255.216.151]:32998 "EHLO
	forward20m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751166AbbLPVEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 16:04:13 -0500
In-Reply-To: <20151216160400.GJ6555@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil,

> Dmitrii, did iproute2 without your change even print the overhead as
set by you before? Looking at the code, I'd assume not.

I used an iproute2 provided by the distribution and an OpenVZ 3.10 kernel
so there are differences there but I
noticed the 'manual' overhead-related code is included there. I am going
to get an upstream kernel and iproute2 to check tomorrow. At least they
print mpu consistently.

The following output is for non-upstream kernels and iproute2 provided
by the distributions so it probably won't be 100% useful to answer your
question.

This is what I have on a quite an old ovz kernel at home:

[root@localhost ~]# uname -r
3.10.0-229.7.2.vz7.8.8
[root@localhost ~]# tc qdisc add dev eth0 root handle 1: htb default 12
[root@localhost ~]# tc class add dev eth0 parent 1: classid 1:1 htb rate
100kbps ceil 100kbps mpu 256 overhead 64
[root@localhost ~]# tc -d class show dev eth0
class htb 1:1 root prio 0 quantum 10000 rate 800000bit overhead 64 ceil
800000bit burst 1600b/1 mpu 0b overhead 1b cburst 1600b/1 mpu 0b
overhead 1b level 0

And this is the same on ubuntu 14.04 with 3.19 kernel (looks like the
mpu value is not configured properly which is strange, though 'manual'
overhead is there).

administrator@ubuntu-q87:~$ uname -r
3.19.0-33-generic

administrator@ubuntu-q87:~$ sudo tc qdisc add dev eth0 root handle 1:
htb default 12
administrator@ubuntu-q87:~$ sudo tc class add dev eth0 parent 1: classid
1:1 htb rate 100kbps ceil 100kbps mpu 256 overhead 64
administrator@ubuntu-q87:~$ tc -d class show dev eth0
class htb 1:1 root prio 0 quantum 10000 rate 800000bit overhead 64 ceil
800000bit linklayer ethernet burst 1600b/1 mpu 0b overhead 0b cburst
1600b/1 mpu 0b overhead 0b level 0

Thanks,
Dima
