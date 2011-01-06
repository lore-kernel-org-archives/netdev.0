From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bad TCP timestamps on non-PC platforms
Date: Thu, 06 Jan 2011 09:09:16 +0100
Message-ID: <1294301356.2723.73.camel@edumazet-laptop>
References: <219643.83181.qm@web37604.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex Dubov <oakad@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39017 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356Ab1AFIJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 03:09:21 -0500
Received: by wyb28 with SMTP id 28so16161676wyb.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 00:09:20 -0800 (PST)
In-Reply-To: <219643.83181.qm@web37604.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 janvier 2011 =C3=A0 22:55 -0800, Alex Dubov a =C3=A9crit=
 :
> Greetings.
> I'm dealing with 2.6.37-rc7 kernel on MPC8548 platform.
>=20
> It so appears, that recent kernels have sysctl_tcp_timestamps set to =
"1"
> by default.
>=20
> On embedded platforms, where real time clock is initialized lately or
> absent outright, this causes TSval field of outgoing TCP packets to b=
e
> set to some garbage value, in my case in the vicinity of 0xffffffff. =
As a
> result, other Linux machines silently drop such packets, preventing n=
ormal
> completion of network boot or any other TCP dependent operation.
>=20
> Therefore, I feel, two changes are necessary (I can send in a patch):
> 1. Make sysctl_tcp_timestamps value config-time selectable (it must b=
e
> disabled by default on machines without RTC).
> 2. When re-enabling tcp_timestamps through sysctl, reset the timestam=
p
> counter to the current system clock value.
>=20
> And an optional, tricky one:
> 3. Postpone TCP timestamp counter initialization until RTC is actuall=
y
> available (if RTC is connected to i2c bus, TCP is initialized well ah=
ead
> of it).
>=20

I am trying to understand the problem, but I guess you hit something no=
t
related to RTC at all.

#define tcp_time_stamp		((__u32)(jiffies))
#define INITIAL_JIFFIES ((unsigned long)(unsigned int) (-300*HZ))

jiffies can be ZERO 300 seconds after boot.

It should not matter with RFC1323. Some TCP session could in theory be
done without TCP timestamps being activated (because SYN paquet would
carry a ZERO  tsval/tsecr), but this should not prevents normal network
operation.

Are you sure the "other linux machines" dont have
strange /etc/sysctl.conf settings ?



