From: Arkadiusz Miskiewicz <arekm@pld-linux.org>
Subject: ip a flush problem on 2.6 kernels (fine on 2.4 kernels)
Date: Thu, 4 Mar 2004 03:08:15 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200403040308.15880.arekm@pld-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: lkml <linux-kernel@vger.kernel.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

The problem is that

ip a a 192.168.0.1/24 dev eth0
ip link set eth0 down
ip a flush dev eth0

Here on my vanilla 2.6.2 it locks eating CPU - it does netlink=20
communication over and over. This ,,hang'' doesn't happen when=20
interface is in UP state. Also doesn't happen on 2.4 kernels.

I've tried it on different 2.6 kernels (one from fedora, one from PLD) =
with=20
different versions of iproute2 (usually latest). Friend tried it also w=
ith=20
iproute2 from slackware - same result.

Same happens when using lo interface instead of ethX.

More description in RH bugzilla:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D116982

ps. doing that on Broadcom Corporation BCM4401 100Base-T ethX interface=
 (using=20
b44 driver) causes lock (but sysrq works) on 2.4.25 kernel. Would be ni=
ce if=20
someone with that hardware could verify this.
--=20
Arkadiusz Mi=B6kiewicz     CS at FoE, Wroclaw University of Technology
arekm.pld-linux.org, 1024/3DB19BBD, JID: arekm.jabber.org, PLD/Linux
