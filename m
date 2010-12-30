From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why do programs freeze with big network transfers?
Date: Thu, 30 Dec 2010 08:58:39 +0100
Message-ID: <1293695919.7150.18.camel@edumazet-laptop>
References: <ifhc54$efg$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Adam Nielsen <a.nielsen@shikadi.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ifhc54$efg$1@dough.gmane.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 30 d=C3=A9cembre 2010 =C3=A0 17:25 +1000, Adam Nielsen a =C3=A9=
crit :
> Hi all,
>=20
> I'm a bit stuck on this problem so I hope someone can help.  My deskt=
op PC is=20
> running kernel 2.6.33.1 and when I copy some largish files (2-3GB eac=
h) onto=20
> an NFS share my PC becomes unusable, pretty much locking up for 60 se=
conds at=20
> a time.
>=20
> Everything works fine for a little while once the copy has begun - th=
e files=20
> are read off the software-RAID-0 disks at about 200MB/sec, then after=
 10=20
> seconds or so data starts going across the gigabit network at about 4=
0MB/sec=20
> (speed limited by the target system which pegs at 100% CPU due to lac=
k of=20
> jumbo packets.)
>=20
> After a few seconds of data going over the network, X-Windows freezes=
=2E  No=20
> screen updates, the mouse cursor won't move, for all intents and purp=
oses the=20
> system has frozen solid.  I'm playing music with XMMS2 and that keeps=
 going,=20
> but occasionally even that stops too.  After a minute (between 45 and=
 65=20
> seconds) everything unfreezes and keeps going as per normal.  Less th=
an 10=20
> seconds later everything freezes again for another minute!  This keep=
s going=20
> until the file transfer has finished.
>=20
> When things unfreeze the disk is idle, and within 10 seconds the disk=
 starts=20
> up again and almost immediately the next minute-long freeze begins.  =
While=20
> things are frozen the network transfer continues, and bizarrely I can=
 log in=20
> to the machine over SSH where everything seems normal.  'top' reports=
 most=20
> processes are idle, and running a command line XMMS2 client happily r=
eports=20
> that the song I am listening to is stuck at exactly the same point un=
til the=20
> freeze is over, when the seconds start counting up again.
>=20
> The reason I am stuck is that nothing is appearing in dmesg, so it ap=
pears the=20
> kernel is unaware of the problem.  Has anyone seen anything like this=
 before?=20
>   I'm not sure what to do next.
>=20
> Disks are connected to an Intel ICH9 SATA controller in AHCI mode, LA=
N is a=20
> Realtek 8169, video card is nVidia GeForce 8600.  Perhaps some combin=
ation of=20
> this is to blame?
>=20
> I have tried using cat to read these files into /dev/null and the sys=
tem will=20
> happily read the files at full speed without freezing, and I have use=
d ttcp's=20
> speed test function to send data over the network at full speed, whic=
h also=20
> works without X11 freezing.  Doing this at the same time (reading fro=
m the=20
> disk and sending network traffic) also works fine without locking up,=
 so it=20
> seems the problems only arise when NFS gets involved.
>=20
> 'mount' reports the options on the NFS share as:
>    rw,user=3Dadam,tcp,soft,intr,timeo=3D20,vers=3D3,addr=3D192.168.0.=
6
>=20
> Any suggestions about what I can do next?
>=20
> Many thanks,
> Adam.

CC netdev

This rings a bell here, could you try to apply commit=20

482964e56e1320cb7952faa1932d8ecf59c4bf75
(net: Fix the condition passed to sk_wait_event())

This commit was included in 2.6.36, so you could also try 2.6.36.2
kernel.

http://git2.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D482964e56e1320cb7952faa1932d8ecf59c4bf75

Thanks
