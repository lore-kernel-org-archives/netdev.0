From: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is
  dropped after ~40 seconds
Date: Fri, 18 Dec 2009 08:56:39 +0100
Message-ID: <4B2B35B7.6060703@freemail.hu>
References: <bug-14794-10286@http.bugzilla.kernel.org/>	<20091216154713.f082e7cf.akpm@linux-foundation.org>	<4B2A9A40.90203@freemail.hu> <20091217132451.b168a796.akpm@linux-foundation.org> <4B2AA64C.50709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02a.mail.t-online.hu ([84.2.40.7]:54164 "EHLO
	mail02a.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186AbZLRIDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 03:03:49 -0500
In-Reply-To: <4B2AA64C.50709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Jarek Poplawski wrote:
> Andrew Morton wrote, On 12/17/2009 10:24 PM:
>=20
>> On Thu, 17 Dec 2009 21:53:20 +0100
>> N=E9meth M=E1rton <nm127@freemail.hu> wrote:
>>
>>> Hi,
>>>
>>> I bisected the problem, see http://bugzilla.kernel.org/show_bug.cgi=
?id=3D14794
>>> for details. Any idea what is the relation between this problem and=
 the found
>>> patch?
>>>
>> : 61cbe54d9479ad98283b2dda686deae4c34b2d59 is the first bad commit
>> : commit 61cbe54d9479ad98283b2dda686deae4c34b2d59
>> : Author: Mike Galbraith <efault@gmx.de>
>> : Date:   Wed Sep 9 15:41:37 2009 +0200
>> :
>> :    sched: Keep kthreads at default priority
>>
>> Strange.  Might be a timing thing bu a) I doubt if any kernel thread=
s
>> are involved in maintaining a DHCP lease and b) even if they were, s=
uch
>> a race wouldn't be this repeatable.
>>
>=20
> "Removes kthread/workqueue priority boost[...]" - if there could be
> workqueues involved - maybe something with link-watch?

Unfortunately reverting the commit 61cbe54d9479ad98283b2dda686deae4c34b=
2d59 on
top of 2.6.32 does not solve the problem.

I use KDE, and the KNetworkManager icon is visible on the task bar. Whe=
n
I unplug the network cable the "disconnected" icon appears. After I plu=
g the
network cable again, a rotating wheel appears. Here comes the differenc=
e: *when*
the rotating wheel changes to "connected" state. One case, when the IP =
address
is kept the "connected" icon appears right after the IP address assigne=
d by
DHCP appears in the ifconfig output. In the wrong case this rotating wh=
eel is
still there for about 60 seconds while the the assigned IP address is d=
ropped
and an IP address like 169.254.123.251 is assigned.

There is a workaround, too. If the IP address 169.254.123.251 was assig=
ned and
I execute "dhclient eth0" as root, an IP address will be assigned by DH=
CP and
this address is not dropped anymore until I again unplug and replug the=
 network
cable.

My driver for the network card is 8139too. My network card is:

00:08.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8=
139C/8139C+ (rev 10)
        Subsystem: CLEVO/KAPOK Computer Device 4702
        Flags: bus master, medium devsel, latency 64, IRQ 19
        I/O ports at 1000 [size=3D256]
        Memory at d0004000 (32-bit, non-prefetchable) [size=3D256]
        Capabilities: [50] Power Management version 2
        Kernel driver in use: 8139too
        Kernel modules: 8139too

Regars,

	M=E1rton N=E9meth
