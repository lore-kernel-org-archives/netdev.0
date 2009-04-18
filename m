From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: rfkill rewrite bug
Date: Sat, 18 Apr 2009 10:15:42 +0200
Message-ID: <1240042543.4836.2.camel@johannes.local>
References: <49DCA88E.6060400@tuffmail.co.uk>
	 (sfid-20090408_153722_059382_FB44D658) <1239204090.16477.1.camel@johannes.local>
	 <49DCDD2E.80705@tuffmail.co.uk>  <49E38BBC.5010708@tuffmail.co.uk>
	 (sfid-20090413_205524_915082_56358705) <1239741968.4205.1.camel@johannes.local>
	 <49E98C86.2040308@tuffmail.co.uk> (sfid-20090418_101208_980691_83127E2F)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-ciBpW1XvJ081xtiOyRMs"
Cc: netdev@vger.kernel.org
To: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37309 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbZDRIPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 04:15:48 -0400
In-Reply-To: <49E98C86.2040308@tuffmail.co.uk> (sfid-20090418_101208_980691_83127E2F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ciBpW1XvJ081xtiOyRMs
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi!

> Ok, I retried with v6.  It seemed to work well enough; my wireless=20
> toggle key worked and either state was preserved over suspend and=20
> hibernation.

Alright, cool.

> When I looked at the code earlier, I saw no obvious replacement for=20
> rfkill_set_default().  So I tried disabling the wireless and rebooting=20
> to see what happened.  It didn't like that :-).

Oops. I'll take a look tonight, thanks for testing!

johannes

> [    3.258061] ------------[ cut here ]------------
> [    3.258160] kernel BUG at kernel/workqueue.c:192!
> [    3.258256] invalid opcode: 0000 [#1]
> [    3.258391] last sysfs file: /sys/module/backlight/initstate
> [    3.258489] Modules linked in: video(+) output eeepc_laptop(+)=20
> backlight ac battery rfkill but
> ton processor evdev thermal fan ata_generic
> [    3.259261]
> [    3.259346] Pid: 1571, comm: modprobe Not tainted (2.6.30-rc2-wleeepc=20
> #13) 701
> [    3.259482] EIP: 0060:[<c0129e0a>] EFLAGS: 00010203 CPU: 0
> [    3.259590] EIP is at queue_work_on+0x1a/0x31
> [    3.259687] EAX: df089730 EBX: df00a060 ECX: df08972c EDX: 00000000
> [    3.259790] ESI: e0045f54 EDI: df284800 EBP: df361e3c ESP: df361e38
> [    3.259893]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> [    3.259996] Process modprobe (pid: 1571, ti=3Ddf360000 task=3Dde853c00=
=20
> task.ti=3Ddf360000)
> [    3.260131] Stack:
> [    3.260160]  df089600 df361e44 c0129e41 df361e4c c0129e52 df361e5c=20
> e00125f7 00010000
> [    3.260160]  df09c400 df361e80 e00458b9 00000000 00000200 00000010=20
> de59ae90 df284800
> [    3.260160]  ffffffed e0047474 df361e9c c02116c3 df2849fc ffffffda=20
> df2849fc f
> fffffed
> [    3.260160] Call Trace:
> [    3.260160]  [<c0129e41>] ? queue_work+0xe/0x10
> [    3.260160]  [<c0129e52>] ? schedule_work+0xf/0x11
> [    3.260160]  [<e00125f7>] ? rfkill_set_sw_state+0x4c/0x69 [rfkill]
> [    3.260160]  [<e00458b9>] ? eeepc_hotk_add+0x2c7/0x3ec [eeepc_laptop]
> [    3.260160]  [<c02116c3>] ? acpi_device_probe+0x44/0x127
> [    3.260160]  [<c0249719>] ? driver_probe_device+0x7f/0xf2
> [    3.260160]  [<c02497cf>] ? __driver_attach+0x43/0x5f
> [    3.260160]  [<c0248dcb>] ? bus_for_each_dev+0x39/0x5a
> [    3.260160]  [<c02495ec>] ? driver_attach+0x14/0x16
> [    3.260160]  [<c024978c>] ? __driver_attach+0x0/0x5f
> [    3.260160]  [<c02492cf>] ? bus_add_driver+0xd7/0x1e7
> [    3.260160]  [<c02499d5>] ? driver_register+0x7b/0xd7
> [    3.260160]  [<c0212d44>] ? acpi_bus_register_driver+0x3a/0x3c
> [    3.260160]  [<e004a022>] ? eeepc_laptop_init+0x22/0x1b9 [eeepc_laptop=
]
> [    3.260160]  [<c0101131>] ? _stext+0x49/0x10b
> [    3.260160]  [<e004a000>] ? eeepc_laptop_init+0x0/0x1b9 [eeepc_laptop]
> [    3.260160]  [<c012f476>] ? __blocking_notifier_call_chain+0x40/0x4c
> [    3.260160]  [<c013a738>] ? sys_init_module+0x87/0x18f
> [    3.260160]  [<c0102804>] ? sysenter_do_call+0x12/0x22
> [    3.260160] Code: 83 e2 fc 8b 4a 14 89 c2 8b 01 e8 d9 ff ff ff 5d c3=20
> 55 89 e5 53 89 d3 0f ba 29 00 19 c0 31 d2 85 c0 75 1a 8d 41 04 39 41 04=20
> 74 04 <0f> 0b eb fe 8b 03 89 ca e8 b0 ff ff ff ba 01 00 00 00 5b 89 d0
> [    3.260160] EIP: [<c0129e0a>] queue_work_on+0x1a/0x31 SS:ESP=20
> 0068:df361e38
> [    3.269670] ---[ end trace f8b6941350b5e97c ]---
>=20
> Thanks
> Alan
>=20

--=-ciBpW1XvJ081xtiOyRMs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJ6YwrAAoJEKVg1VMiehFY4D4QAMIs49jkz9raCwovXC3Ot5Bt
akqgVRDJHfU53VB8qAZ2lPBRyBXrEQr3URr4u5MsUjxfZpdU0MeZ+GTm6P8mk6NR
bnjwpDfCqNWeB8M3xkWRTntKdxFOPbSgAzsRBCcV5+QpSxepVkskWm0hGh92muYL
Ixo5ruL/kQrK9CaDzLkjYHHmeJU8r2FacvxSm0kHK4Vwf5spvuI5JQBUxENcuth0
suGFsIITCrYEpNLZGfL+yNokyZ1jFjSGFnN2i0usvw3q2QRekK62Yeajuyg4G+TU
V9XrJ52eGhvTYCe2JBYH1ykW1ldv8Dm6Q+rQ4L72UR11iQY8OpYJLQ3sO3dSZ6J3
yoq1T239eQqtZ4u+ZyKEe0+n5YqFQYVXMCh08o0Xc8kaD/DtwzbP5NIVqTY3N1kP
54EhQY2AccbHax05DVsQs0g8Z0ipeIDVRUbDPR20UEqKGoaidGf2cl+EPTHXtR36
iVTVru1ODfWQNEX/ptOjg1reG5NqJIbVNXNQKr3gsIW8060yd9aTTPGkc86pXJbV
TbawCFxC6H7286bgAkco+zJ/veMetk/QG3EONY3KDshXqARWI9fMB4yB3RKWFkBY
xGn0NIgaAmbyARy94TrGaWjG5us4/BdqG4G6wU7BSN21kl9MSlsPUPuCiJvW8xun
qlOCfzrZnOWRALXbboEf
=PpRf
-----END PGP SIGNATURE-----

--=-ciBpW1XvJ081xtiOyRMs--

