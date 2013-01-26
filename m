From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
Subject: How to find an unused TAP device with kernel 3.8 ?
Date: Sat, 26 Jan 2013 11:29:49 +0100
Message-ID: <5103B01D.5070303@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With kernel 3.8. I just realized that all pre-defined TAP devices are
RUNNING even if no virtual linux system is using it. Now I'm wondering
whether this is a new feature of the upcoming kernel, a bug of the old =
-
and how I can avoid that.

Background : When I start a user mode linux instance, I currently grep
for the next free tap device in this way :

Code:=09
for t in $(ifconfig | grep "^tap" | cut -f1 -d:)
do
   ethtool $t | grep -q 'Link detected: no'
   if [[ $? -eq 0 ]]; then
      NET=3D"tuntap,$t"
      break
   fi
done

but this doesn't work now anymore.

Here is the diff in dmesg

$ diff 3.7.1 3.8.0-rc1+ | grep UP

< br0: flags=3D4355<UP,BROADCAST,PROMISC,MULTICAST>  mtu 1500
> br0: flags=3D4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 1500

< tap0: flags=3D4099<UP,BROADCAST,MULTICAST>  mtu 1500
> tap0: flags=3D4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500


more details : http://forums.gentoo.org/viewtopic-p-7211498.html#721149=
8


--=20
MfG/Sincerely
Toralf F=C3=B6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
