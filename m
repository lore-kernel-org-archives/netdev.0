From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Fri, 17 Oct 2008 20:51:49 -0300
Message-ID: <48f9251b.1626360a.6574.61ec@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
	<48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
	<alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
	<Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
	<48e5364d.0603c00a.6e25.fffff993@mx.google.com>
	<Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
	<48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com>
	<alpine.LFD.2.00.0810052008131.3398@apollo>
	<48ed0b51.0913c00a.7715.4aa7@mx.google.com>
	<alpine.LFD.2.00.0810082154420.3237@apollo>
	<48f2c9d7.0603c00a.1df2.ffff9357@mx.google.com>
	<Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.176]:36028 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280AbYJQXv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 19:51:59 -0400
Received: by el-out-1112.google.com with SMTP id z25so215208ele.1
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2008 16:51:58 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Oct 2008 16:35:08 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

	Just reporting another stall event... Who knows it helps in some way..=
=2E

> ...might turn out related. It has somewhat similar problem though=20
> different syscall. Not enough info on what kernel version etc.=20
> there though.

	Well, I can be wrong, but I think those stalls are related to USB (or =
USB helped to=20
"solve" the stall temporarily)... I explain below (I have a monitor wit=
h usb hub connected):

Oct 17 19:35:55 tux sudo: pam_unix(sudo:session): session opened for us=
er root by fraga(uid=3D0)
Oct 17 19:35:55 tux sudo: pam_unix(sudo:session): session closed for us=
er root

	^---------- sudo opened the session at 19:35

Oct 17 19:38:16 tux sudo:    fraga : TTY=3Dpts/2 ; PWD=3D/usr/local/lib=
 ; USER=3Droot ; COMMAND=3D/usr/local/bin/rm libdvdread.a libdvdread.la=
 libdvdread.so libdvdread.so.3 libdvdread.so.3.2.1 libdvdread.so.4 libd=
vdread
=2Eso.4.1.2

	^---------- I tried to run this command with sudo. And it stalled. Not=
ice that it was logged only on 19:38.

Oct 17 19:38:16 tux sudo: pam_unix(sudo:session): session opened for us=
er root by fraga(uid=3D0)
Oct 17 19:38:16 tux sudo: pam_unix(sudo:session): session closed for us=
er root
Oct 17 19:40:20 tux vmunix: ci000/000:21ub/-/-./-../-..:./nu/nu7

	^----------- Here is the stall. You can see that the log is corrupted,=
 every other line.

Oct 17 19:40:20 tux vmunix: 6ipt S I 11 os Lgtc pia S os]o s-000:21112

	^----------- Every other line. Here is when I turned off my monitor wi=
th USB... Unless it was an extreme coincidence, I'm sure this event
of turning off and...

Oct 17 19:40:25 tux vmunix: sd 9:0:0:0: [sdb] Attached SCSI removable d=
isk
Oct 17 19:40:25 tux scsi.agent[5498]: disk at /devices/pci0000:00/0000:=
00:02.1/usb2/2-1/2-1.1/2-1.1.1/2-1.1.1:1.0/host9/target9:0:0/9:0:0:0

	^---------- ...turning on again, helped to "solve" the stall. The stal=
l ended when I turned off the monitor.

Oct 17 19:40:28 tux sudo:    fraga : TTY=3Dpts/2 ; PWD=3D/usr/local/lib=
 ; USER=3Droot ; COMMAND=3D/usr/local/bin/ls
Oct 17 19:40:28 tux sudo: pam_unix(sudo:session): session opened for us=
er root by fraga(uid=3D0)
Oct 17 19:40:28 tux sudo: pam_unix(sudo:session): session closed for us=
er root
Oct 17 19:40:30 tux scsi.agent[5310]: Attribute /sys/devices/pci0000:00=
/0000:00:02.1/usb2/2-1/2-1.1/2-1.1.1/2-1.1.1:1.0/host9/type does not ex=
ist
Oct 17 19:40:35 tux scsi.agent[5493]: Attribute /sys/devices/pci0000:00=
/0000:00:02.1/usb2/2-1/2-1.1/2-1.1.1/2-1.1.1:1.0/host9/target9:0:0/type=
 does not exist
Oct 17 20:12:37 tux vmunix: usb-storage: device found at 14
Oct 17 20:12:37 tux vmunix: usb-storage: waiting for device to settle b=
efore scanning
Oct 17 20:12:42 tux vmunix: scsi 10:0:0:0: Direct-Access     Generic  l=
s SC   53 Q  NI=20
Oct 17 20:12:42 tux vmunix: k
Oct 17 20:12:42 tux scsi.agent[7439]: disk at /devices/pci0000:00/0000:=
00:02.1/usb2/2-1/2-1.1/2-1.1.1/2-1.1.1:1.0/host10/target10:0:0/10:0:0:0
Oct 17 20:12:47 tux vmunix: DROP INPUT: IN=3Deth0 OUT=3D MAC=3Dff:ff:ff=
:ff:ff:ff:00:15:e9:e2:00:db:08:00 SRC=3D192.168.0.1 DST=3D255.255.255.2=
55 LEN=3D334 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D6668 PROTO=3DUDP SPT=3D=
67 DPT=3D68 LEN=3D314=20
Oct 17 20:12:47 tux scsi.agent[7252]: Attribute /sys/devices/pci0000:00=
/0000:00:02.1/usb2/2-1/2-1.1/2-1.1.1/2-1.1.1:1.0/host10/type does not e=
xist
Oct 17 20:12:53 tux scsi.agent[7435]: Attribute /sys/devices/pci0000:00=
/0000:00:02.1/usb2/2-1/2-1.1/2-1.1.1/2-1.1.1:1.0/host10/target10:0:0/ty=
pe does not exist

	***
=09
	At the server I have an usb device connected too...

	OR at eh end it's just a symptom of the problem... I don't
know. The interesting thing is that as soon as I turned off the monitor=
=20
(at the exact moment), the speaker beeped, because I used TAB to auto
complete my command, and I knew that sudo wasn't stalled
anymore.

	Maybe what the kernel does when we remove a usb hub could give us a hi=
nt about the stalling issue...

--=20
