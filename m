From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH] Documentation, clarify tuntap IPX example.
Date: Wed, 18 Nov 2009 20:03:49 +1100
Message-ID: <d45a3acc0911180103q69499cc6yf610117ea44186d7@mail.gmail.com>
References: <d45a3acc0911171730kc3a03d5iacec6d9ef4b1874c@mail.gmail.com>
	 <4B035081.8040900@qualcomm.com>
	 <d45a3acc0911171814i310bbd16t8ff3fba2410e9375@mail.gmail.com>
	 <4B038BB7.2050902@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f180.google.com ([209.85.216.180]:54490 "EHLO
	mail-px0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755450AbZKRJDn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 04:03:43 -0500
In-Reply-To: <4B038BB7.2050902@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Max,

Thanks. TUNSETLINK looks like exactly what I need.
I'll have to have a closer look at kernel x.25 next, i don't think it
likes the tunx25 going away with routes still too it.

deb32:~# cat /proc/net/x25/route
Address          Digits  Device
000000000000000  0       @=EF=BF=BD=18=EF=BF=BD=EF=BF=BD
                              =18=EF=BF=BD@=EF=BF=BD=1D

[  662.425648] BUG: unable to handle kernel NULL pointer dereference at=
 00000017
[  662.426291] IP: [<c10b5908>] dup_fd+0x21f/0x2fa
[  662.427849] *pde =3D 00000000
[  662.428028] Oops: 0002 [#1] SMP
[  662.428028] last sysfs file: /sys/class/net/lo/operstate
[  662.428028] Modules linked in: x25 tun ipv6 loop ac button
parport_pc parport snd_pcm snd_timer serio_raw psmouse snd soundcore
snd_page_alloc pcspkr i2c_piix4 i2c_core evdev ext3 jbd mbcache
ide_cd_mod cdrom ide_gd_mod ata_generic ata_piix libata scsi_mod
ide_pci_generic piix floppy pcnet32 mii ide_core thermal fan
thermal_sys [last unloaded: tun]
[  662.428028]
[  662.428028] Pid: 12252, comm: net.agent Not tainted (2.6.31.6 #1) Vi=
rtualBox
[  662.428028] EIP: 0060:[<c10b5908>] EFLAGS: 00010286 CPU: 0
[  662.428028] EIP is at dup_fd+0x21f/0x2fa
[  662.428028] EAX: 00000017 EBX: ce5262a0 ECX: 00000220 EDX: ffffffff
[  662.428028] ESI: 00000088 EDI: ce41e400 EBP: 00000100 ESP: c2849eec
[  662.428028]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0069
[  662.428028] Process net.agent (pid: 12252, ti=3Dc2848000
task=3Dce9d51c0 task.ti=3Dc2848000)
[  662.428028] Stack:
[  662.428028]  00000202 00000020 00000008 cf466cc0 cf466cc4 cf4667c0
ce41e400 00000078
[  662.428028] <0> ce5262c0 cf466d00 cf4667c8 ce02bc00 ce18db60
00000000 00000000 ce9d51c0
[  662.428028] <0> c102d03b 080a8120 cf649668 c2849fb4 bfe05a6c
01200011 ce18dca4 fffffff4
[  662.428028] Call Trace:
[  662.428028]  [<c102d03b>] ? copy_process+0x469/0xf96
[  662.428028]  [<c102dc7d>] ? do_fork+0x115/0x282
[  662.428028]  [<c10a4965>] ? vfs_llseek+0x30/0x34
[  662.428028]  [<c1001d8e>] ? sys_clone+0x21/0x27
[  662.428028]  [<c10030c9>] ? syscall_call+0x7/0xb
[  662.428028] Code: 4c 24 08 8b 70 08 f3 a5 8b 4c 24 04 83 e1 03 74
02 f3 a4 31 c9 31 f6 89 6c 24 1c eb 29 8b 7c 24 18 8b 14 0f 85 d2 74
09 8d 42 18 <3e> ff 42 18 eb 06 8b 43 0c 0f b3 30 8b 44 24 2c 46 89 14
08 83
[  662.428028] EIP: [<c10b5908>] dup_fd+0x21f/0x2fa SS:ESP 0069:c2849ee=
c
[  662.428028] CR2: 0000000000000017
[  662.452941] ---[ end trace aab1610cb3ca8b89 ]---

Message from syslogd@deb32 at Nov 19 06:58:56 ...
 kernel:[  904.324109] unregister_netdevice: waiting for xotdtun to
become free. Usage count =3D -3


Andrew

On Wed, Nov 18, 2009 at 4:52 PM, Max Krasnyansky <maxk@qualcomm.com> wr=
ote:
> andrew hendry wrote:
>> Hi Max,
>>
>> I started looking through the documentation because im looking to us=
e
>> tun for X.25 over TCP. The IPX example sounded similar but i couldn'=
t
>> get it to work as I was expecting. Looking for a hint in the right
>> direction.
> Ah, X25 is different.
>
>> There is an old non-mainline patch called x25tap (clone of obsolete
>> ethertap). I'm hoping to replace x25tap with tun.
>>
>> The old x25tap creates a device like:
>> x25tap0 =C2=A0 Link encap:generic X.25 =C2=A0HWaddr
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 UP BROADCAST RUNNING NOARP MULTIC=
AST =C2=A0MTU:1024 =C2=A0Metric:1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RX packets:3040785 errors:0 dropp=
ed:0 overruns:0 frame:0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 TX packets:2895530 errors:0 dropp=
ed:0 overruns:0 carrier:0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 collisions:0 txqueuelen:10
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RX bytes:138787339 (132.3 Mb) =C2=
=A0TX bytes:91395983 (87.1 Mb)
>> When the x25tap is loaded it has dev->type =3D ARPHRD_X25, after whi=
ch
>> x.25 routing and AF_X25 sockets can be created. =C2=A0Along with an =
XoT
>> userspace program which handles some basic headers and TCP port 1998
>> it works well.
>>
>> If using tun, how does something get registered to handle protocol A=
=46_X25?
>>
>
> I've never tried this personally so ... :). But I just glanced over n=
et/ax25
> and drivers/wan/ax25 and it looks TUNSETLINK might work for you.
> In other words you want to allocate TUN device (not TAP) and then cal=
l
> TUNSETLINK with ARPHRD_X25. Seems like you'll get exactly what you ne=
ed.
>
> Max
>
>
>> Regards,
>> Andrew.
>>
>> On Wed, Nov 18, 2009 at 12:40 PM, Max Krasnyansky <maxk@qualcomm.com=
> wrote:
>>> On 11/17/2009 05:30 PM, andrew hendry wrote:
>>>> Can the TUNSETIFF ioctl change a tap's protocol to IPX as the
>>>> documentation suggests?
>>>> I think tun.c would need IFF_IPX_TAP added for it to work as descr=
ibed?
>>>> Otherwise tap can only be ptp or ethernet, and there is no way to
>>>> route or use AF_IPX.
>>> TAP is an Ethernet device. No special handling is required for IPX =
or for
>>> that matter any other protocol. Example seems fine too.
>>>
>>> Max
>>>
>>>> Signed-off-by: Andrew Hendry<andrew.hendry@gmail.com>
>>>>
>>>> --- a/Documentation/networking/tuntap.txt =C2=A0 =C2=A0 =C2=A0 200=
9-11-11
>>>> 14:03:22.676167648 +1100
>>>> +++ b/Documentation/networking/tuntap.txt =C2=A0 =C2=A0 =C2=A0 200=
9-11-18
>>>> 11:34:18.106647029 +1100
>>>> @@ -127,12 +127,14 @@ Ethernet device, which instead of receiv
>>>> =C2=A0media, receives them from user space program and instead of =
sending
>>>> =C2=A0packets via physical media sends them to the user space prog=
ram.
>>>>
>>>> -Let's say that you configured IPX on the tap0, then whenever
>>>> -the kernel sends an IPX packet to tap0, it is passed to the appli=
cation
>>>> -(VTun for example). The application encrypts, compresses and send=
s it to
>>>> -the other side over TCP or UDP. The application on the other side
>>>> decompresses
>>>> -and decrypts the data received and writes the packet to the TAP d=
evice,
>>>> -the kernel handles the packet like it came from real physical dev=
ice.
>>>> +Let's say for the purpose of example, IPX support was added to tu=
ntap.
>>>> +Then whenever the kernel routes an IPX packet to tap0, it is pass=
ed to
>>>> the
>>>> +application reading the file descriptor from /dev/net/tun (VTun f=
or
>>>> example).
>>>> +The application encrypts, compresses and sends it to the other si=
de over
>>>> TCP
>>>> +or UDP. The application on the other side decompresses and decryp=
ts the
>>>> data
>>>> +received and writes the packet to the TAP device, the remote kern=
el
>>>> handles
>>>> +the packet like it came from real physical device. The IPX applic=
ations
>>>> are
>>>> +able to communicate as if there was a real IPX network.
>>>>
>>>> =C2=A04. What is the difference between TUN driver and TAP driver?
>>>> =C2=A0TUN works with IP frames. TAP works with Ethernet frames.
>>>
>
>
