From: Grant Grundler <grundler@chromium.org>
Subject: Re: 3.0.8 kernel : NULL ptr deref in skb_queue_purge()
Date: Fri, 6 Jan 2012 13:19:30 -0800
Message-ID: <CANEJEGtfQtcsmGkhNBKHV3Uxaxxy3PjjUU7TLnRhh9UsP79cHA@mail.gmail.com>
References: <CANEJEGtJ3UmFNyui_SaZ6NF5FFVjZ+_UBg1RC2eif5Lu1YKDsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:54369 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759222Ab2AFVTb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 16:19:31 -0500
Received: by obcwo16 with SMTP id wo16so2380022obc.19
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 13:19:30 -0800 (PST)
In-Reply-To: <CANEJEGtJ3UmFNyui_SaZ6NF5FFVjZ+_UBg1RC2eif5Lu1YKDsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2011 at 2:40 PM, Grant Grundler <grundler@chromium.org> =
wrote:
> Hi,
> I'm testing asix (USB 100BT ethernet adapter with AX88772) driver
> initialization (and shut down) paths and reproduced a
> "skb_queue_purge" panic 3 times after a few hundred/thousand
> iterations of rmmod/modprobe. I'm inclined to believe
> skb_queue_purge() is a victim and not a culprit here.

=46YI - Follow up:
I'm not able to reproduce this problem in 10000 iterations of
unload/USB off/USB on/load asix cycles. I've closed the original bug
report (http://crosbug.com/17349).

Our kernel moved forward to 3.0.13 since then (was 3.0.8 based) but
I'm skeptical this 'fixed' the problem. So I think there is something
else going on (memory corruption? don't know).

cheers,
grant

>
> =C2=A0I don't know if all 3 "spontaneous reboots" I've seen have the =
same
> stack trace as the one I have a record for:
>
> ...
> <6>[57776.637311] asix 1-4:1.0: eth0: link up, 100Mbps, full-duplex, =
lpa 0xCDE1
> <6>[57777.224552] usbcore: deregistering interface driver asix
> <6>[57777.224859] asix 1-4:1.0: eth0: unregister 'asix'
> usb-0000:00:1d.7-4, ASIX AX88772 USB 2.0 Ethernet
> <1>[57777.224918] BUG: unable to handle kernel NULL pointer
> dereference at 00000002
> <1>[57777.224934] IP: [<00000002>] 0x1
> <5>[57777.224952] *pdpt =3D 0000000061d70001 *pde =3D 000000000000000=
0
> <0>[57777.224967] Oops: 0010 [#1] SMP
> <5>[57777.224980] Modules linked in: asix(-) i2c_dev tsl2583(C)
> industrialio(C) snd_hda_codec_realtek i2c_i801 nm10_gpio snd_hda_inte=
l
> snd_hda_codec snd_hwdep snd_pcm snd_timer snd_page_alloc gobi rtc_cmo=
s
> fuse nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter xt_mark ath9k
> ip6_tables mac80211 ath9k_common ath9k_hw ath cfg80211 uvcvideo
> videodev usbnet qcserial usb_wwan [last unloaded: asix]
> <5>[57777.225109]
> <5>[57777.225121] Pid: 30292, comm: rmmod Tainted: G =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 C =C2=A03.0.8
> #2 SAMSUNG ELECTRONICS CO., LTD. Alex/G100
> <5>[57777.225141] EIP: 0060:[<00000002>] EFLAGS: 00010286 CPU: 1
> <5>[57777.225153] EIP is at 0x2
> <5>[57777.225162] EAX: 00000001 EBX: 00000100 ECX: 00000000 EDX: 0000=
0100
> <5>[57777.225172] ESI: f6bad5a8 EDI: f6bad59c EBP: e44e7e20 ESP: e44e=
7e14
> <5>[57777.225183] =C2=A0DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> <0>[57777.225194] Process rmmod (pid: 30292, ti=3De44e6000 task=3Df0c=
2e040
> task.ti=3De44e6000)
> <0>[57777.225203] Stack:
> <5>[57777.225209] =C2=A0f58fdb70 f6bad000 f8c63a34 e44e7e2c 812d2a98
> f6bad480 e44e7e40 f87e820e
> <5>[57777.225242] =C2=A0e44e7e88 f6bad000 e44e7e88 e44e7e50 812d79cd
> e44e7e88 f6bad000 e44e7e6c
> <5>[57777.225273] =C2=A0812d7a82 e44e7e58 e44e7e58 e44e7e88 f6bad000
> e44e7e88 e44e7e80 812d7b60
> <0>[57777.225305] Call Trace:
> <5>[57777.225325] =C2=A0[<812d2a98>] skb_queue_purge+0x19/0x20
> <5>[57777.225345] =C2=A0[<f87e820e>] usbnet_stop+0xb5/0xf9 [usbnet]
> <5>[57777.225361] =C2=A0[<812d79cd>] __dev_close_many+0x85/0xa2
> <5>[57777.225375] =C2=A0[<812d7a82>] dev_close_many+0x61/0xb1
> <5>[57777.225390] =C2=A0[<812d7b60>] rollback_registered_many+0x8e/0x=
1ec
> <5>[57777.225405] =C2=A0[<812d9224>] unregister_netdevice_queue+0x6e/=
0x9f
> <5>[57777.225419] =C2=A0[<812d9270>] unregister_netdev+0x1b/0x22
> <5>[57777.225437] =C2=A0[<f87e76be>] usbnet_disconnect+0x71/0xb9 [usb=
net]
> <5>[57777.225454] =C2=A0[<81273a03>] usb_unbind_interface+0x44/0xf8
> <5>[57777.225471] =C2=A0[<81237d25>] __device_release_driver+0x80/0xb=
8
> <5>[57777.225484] =C2=A0[<812381e2>] driver_detach+0x6c/0x8a
> <5>[57777.225499] =C2=A0[<81237c41>] bus_remove_driver+0x6e/0x8d
> <5>[57777.225513] =C2=A0[<81238721>] driver_unregister+0x51/0x58
> <5>[57777.225526] =C2=A0[<812730c2>] usb_deregister+0x92/0x9f
> <5>[57777.225541] =C2=A0[<f8c62885>] cleanup_module+0xd/0x788 [asix]
> <5>[57777.225556] =C2=A0[<810573ed>] sys_delete_module+0x19d/0x1fa
> <5>[57777.225573] =C2=A0[<8109a059>] ? do_munmap+0x1f2/0x20a
> <5>[57777.225590] =C2=A0[<8137e677>] sysenter_do_call+0x12/0x26
> <0>[57777.225599] Code: =C2=A0Bad EIP value.
> <0>[57777.225614] EIP: [<00000002>] 0x2 SS:ESP 0068:e44e7e14
> <0>[57777.225631] CR2: 0000000000000002
> <1>[57777.225035] BUG: unable to handle kernel NULL pointer
> dereference at =C2=A0 (null)
> <1>[57777.225035] IP: [< =C2=A0(null)>] =C2=A0 (null)
> <5>[57777.225035] *pdpt =3D 000000006ff81001 *pde =3D 000000000000000=
0
> <4>[57777.225684] ---[ end trace
>
>
> On my workstation, I run the following to push/run multiple iteration=
s
> on the target system:
> T=3Droot@172.xx.xx.xx
> scp ~/reload_asix $T:/tmp
> for i in `seq 10000`; do printf " %3d: " $i; ssh $T ".
> /tmp/reload_asix" && ssh $T "tail -30 /var/log/messages | fgrep
> leased" ; done | tee reload_asix-loop.out
>
>
> "/tmp/reload_asix" script has the following contents:
> #!/bin/bash -x
>
> # redirect all output to a file. SSH might drop.
> exec > /tmp/`date =C2=A0--rfc-3339=3Ddate`-reload-$$.out 2>&1
>
> date
> rmmod asix
>
> # side effect of auth/deauth is a USB reset on reconnect. :)
> echo 0 > /sys/devices/pci0000:00/0000:00:1d.7/usb1/1-4/authorized
> sleep 1
> echo 1 > /sys/devices/pci0000:00/0000:00:1d.7/usb1/1-4/authorized
> sleep 1
>
> time modprobe asix
>
> for i in `seq 5` ; do
> =C2=A0 =C2=A0 =C2=A0 =C2=A0l=3D"$(cat /sys/class/net/eth0/speed) $(ca=
t /sys/class/net/eth0/duplex)"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printf "%3d: %s %s\n" $i $(cat /sys/class/=
net/eth0/address) "$l"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if [ "$l" =3D "100 full" ] ; then
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fi
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sleep 1
> done
>
> # at this point we have negotiated link..but not DHCP yet. :/
> return 0
>
>
> Reproduced this panic on two different x86 laptops (Asus AGB and
> Samsung Series 5).
>
> At first glance, this doesn't look like an asix driver bug (though it=
 might be).
> I'm hoping the bug will be obvious to someone who understands usbnet
> and skb_queue calls.
> Open to any debugging advice folks have.
>
> thanks in advance,
> grant
