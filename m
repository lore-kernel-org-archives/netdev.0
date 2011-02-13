From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Sun, 13 Feb 2011 08:17:50 +0100
Message-ID: <1297581470.2510.18.camel@edumazet-laptop>
References: <AANLkTin7GBSTcfZgr_9sNZ8CPMkW7Vstni+fs2v1-ink@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ivan Vecera <ivecera@redhat.com>
To: Seblu <seblu@seblu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57898 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab1BMHR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 02:17:59 -0500
In-Reply-To: <AANLkTin7GBSTcfZgr_9sNZ8CPMkW7Vstni+fs2v1-ink@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 13 f=C3=A9vrier 2011 =C3=A0 02:35 +0100, Seblu a =C3=A9crit=
 :
> Hi,
>=20

CC netdev

> Some days ago, one of my computer poweroff without any warning during
> a long rsync. Every time i run this long rsync, my computer power off
> after a random time.
> Firstly i suspected a  heat stroke. But it resisted all my heat tests
> (cpuburn,ffmpeg,etc).
> Secondly i suposed a power issue. But after some tests, it does not
> seem to be kind of problem.
> Thirdly, i trying to load disk by a lot of read. But system is stable=
=2E
>=20
> Which is not practical, is that there is no message or trace in logs
> file. And why power off? BIOS is configured to restart after a
> powerloss.
>=20
> So, maybe a network issue? From one another 1Gbit/s wired linux
> computer i tryed an udp iperf at full speed (got ~950mbps) and after
> some time, host reboot. o0
> I tryed again, and host reboot again. I tryed with "ping -s 65000 -f"
> and my host reboot again. I've tryed this with a 2.6.32 (debian
> squeeze) and a 2.6.37 (debian experimental) kernel, in both case
> host reboot.
>=20
> This doesn't explain why my host power off when rsync, but it seems t=
o
> have a big issue with kernel driver r8169.
>=20
> After starting my flood ping or udp iperf, dmesg show a lot of line:
> [  254.896055] r8169 0000:04:00.0: eth0: link up
> [  254.919976] r8169 0000:04:00.0: eth0: link up
> [  254.943916] r8169 0000:04:00.0: eth0: link up
> [  254.983784] r8169 0000:04:00.0: eth0: link up
> [  255.007710] r8169 0000:04:00.0: eth0: link up
> [  255.031657] r8169 0000:04:00.0: eth0: link up
> [  255.103444] r8169 0000:04:00.0: eth0: link up
>=20
> Reboot is curious because it doesnt look like a kernel panic and prin=
t
> there is no kernel trace.
>=20
> My OS is a debian squeeze amd64. My hardware is a intel core i3 +
> gigabyte H55N-UBS3 with 4G DDR3.
>=20
> Do you need more trace / test? Do you think power off and reboot is l=
inked?
>=20

r8169 driver is known to trigger a reset in case of RX overflow (but a
NIC reset should not power off the machine)

Some attempts were done to avoid a reset on some chipsets.

You could try latest linux-2.6 tree. This includes commits=20

f60ac8e7ab7cbb413a0131d5665b053f9f386526 (r8169: prevent RxFIFO induced
loops in the irq handler.)

1519e57fe81c14bb8fa4855579f19264d1ef63b4 (r8169: RxFIFO overflow
oddities with 8168 chipsets.)

b5ba6d12bdac21bc0620a5089e0f24e362645efd (r8169: use RxFIFO overflow
workaround for 8168c chipset.)





