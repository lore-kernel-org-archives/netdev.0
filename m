From: Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: Linux Kernel Splice Race Condition with page invalidation
Date: Thu, 28 Aug 2008 18:15:27 +0200
Message-ID: <1219940127.6581.194.camel@tucsk>
References: <200808281649.51440.alexandre.lissy@smartjog.com>
	 <1219937801.6581.183.camel@tucsk>
	 <200808281743.58907.alexandre.lissy@smartjog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexandre LISSY <alexandre.lissy@smartjog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:53669 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751292AbYH1QPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 12:15:30 -0400
In-Reply-To: <200808281743.58907.alexandre.lissy@smartjog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, forwarding to mailing lists.

Since you are in a better position to test (already have the
installation and configuration set up) I'm not going to try to reproduc=
e
this until you tried 2.6.26.

Thanks,
Miklos

On Thu, 2008-08-28 at 17:43 +0200, Alexandre LISSY wrote:
> Le Thursday 28 August 2008 17:36:41, vous avez =C3=A9crit :
> > Hi Alexandre,
> >
> > On Thu, 2008-08-28 at 16:49 +0200, Alexandre LISSY wrote:
> > > I saw your mail on LKML, and I feel like I'm experiencing the iss=
ue.
> > > I'm using a 2.6.25-2-amd64 (from Debian), on two machines, one wi=
th 32
> > > bits user land, and the other with 64 bits userland. I also tried=
 with
> > > 2.6.25-2-686.
> >
> > Thanks for the report.  Usually it's best to send such a report not=
 just
> > to an individual developer, but to relevant mailing lists as well (=
in
> > this case <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>)=
=2E
> > Would you mind if I forwarded your mail to these lists?
> No problem, I wasn't sure this was the good audience.
>=20
> >
> > > I'm trying to achieve a really fast tcp proxy, mostly for testing
> > > purpose. Attached is my code, so you can check, and maybe reprodu=
ce :)
> >
> > Thanks.  I don't know how I can use these programs to reproduce the
> > problem.  Can you please describe in detail how to set up and run t=
he
> > test environment?
> Just compile my code, install a icecast that provide a 128k mp3 strea=
m.
> Pay attention, the addresses are hardcoded in source, so you need to =
recompile=20
> for any change.
>=20
> Then, launch many wget or any other tool capable of parallel download=
, to=20
> stress the proxy.
>=20
> >
> > > If I use the local icecast (the one on 127.0.0.1), then, I can re=
ach
> > > 62Mbits, if kernel didn't trashed in the middle of the operation =
(confere
> > > "Kernel having fun"), leaving my process unkillable. Need to rebo=
ot :/.
> >
> > This is because of the kernel BUG that you've reported below.  I fo=
und
> > this similar report:
> Yeah, I figured that's linked :)
>=20
> >
> >   http://article.gmane.org/gmane.linux.network/94988
> >
> > This may have been fixed in linux-2.6.26.  Could you try a 2.6.26
> > kernel, to see if you can still reproduce the problem?
> I'll grab a 2.6.26 from unstable tomorrow and check if it continues t=
o=20
> happens.
>=20
> Thanks for your help :)
>=20
> >
> > Thanks,
> > Miklos
> >
> > > And while it's not trashed, I get many "splice(): Resource tempor=
arily
> > > unavailable", that don't come up when using a remote icecast.
> > >
> > > So, as the only difference is local/remote, I think that latency =
matters,
> > > and considering your message about a race condition, I'm wonderin=
g ...
> > >
> > > Thanks for any help/hint !
> > >
> > > ---Kernel having fun---
> > > [65611.886737] BUG: unable to handle kernel NULL pointer derefere=
nce at
> > > 0000000000000008
> > > [65611.886737] IP: [<ffffffff803db40d>] tcp_read_sock+0xec/0x1a3
> > > [65611.886737] PGD 1fc64067 PUD 2f2a7067 PMD 0
> > > [65611.886737] Oops: 0002 [1] SMP
> > > [65611.886737] CPU 1
> > > [65611.886737] Modules linked in: ipv6 bonding dm_snapshot dm_mir=
ror
> > > dm_mod loop iTCO_wdt ses i5000_edac pcspkr psmouse evdev dcdbas r=
ng_core
> > > button edac_core ixgbe shpchp pci_hotplug serio_raw enclosure ext=
3 jbd
> > > mbcache raid1 md_mod ide_generic ide_cd_mod cdrom ata_generic lib=
ata dock
> > > sd_mod piix ide_core ehci_hcd uhci_hcd megaraid_sas bnx2 firmware=
_class
> > > scsi_mod thermal processor fan
> > > [65611.886737] Pid: 18679, comm: epoll+splice+st Not tainted
> > > 2.6.25-2-amd64 #1 [65611.886737] RIP: 0010:[<ffffffff803db40d>]=20
> > > [<ffffffff803db40d>] tcp_read_sock+0xec/0x1a3
> > > [65611.886737] RSP: 0018:ffff81006db59e68  EFLAGS: 00010202
> > > [65611.886737] RAX: 0000000000000000 RBX: ffff810073c504a0 RCX:
> > > 0000000000000000
> > > [65611.886737] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> > > ffff810073c504a0
> > > [65611.886737] RBP: 0000000000000578 R08: ffff81006d5a2080 R09:
> > > 0000000000000000
> > > [65611.886737] R10: ffff810065663980 R11: ffffffff802f0637 R12:
> > > 0000000000000578
> > > [65611.886737] R13: ffff81006d5a2080 R14: 000000001e5b23ed R15:
> > > ffff81006d5a2130
> > > [65611.886737] FS:  0000000000be2850(0063) GS:ffff81007f76db40(00=
00)
> > > knlGS:0000000000000000
> > > [65611.886737] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > [65611.886737] CR2: 0000000000000008 CR3: 0000000061b55000 CR4:
> > > 00000000000006e0
> > > [65611.886737] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > > 0000000000000000
> > > [65611.886737] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> > > 0000000000000400
> > > [65611.886737] Process epoll+splice+st (pid: 18679, threadinfo
> > > ffff81006db58000, task ffff81007ee45180)
> > > [65611.886737] Stack:  ffffffff803db596 ffff81006db59eb8 00000578=
2628a210
> > > ffff81006d5a2080
> > > [65611.886737]  0000000000000000 0000000000000000 000000000000000=
7
> > > 0000000000000000
> > > [65611.886737]  0000000000000578 ffffffff803dbb14 000000000000000=
0
> > > 0000000000000000
> > > [65611.886737] Call Trace:
> > > [65611.886737]  [<ffffffff803db596>] ? tcp_splice_data_recv+0x0/0=
x1c
> > > [65611.886737]  [<ffffffff803dbb14>] ? tcp_splice_read+0x82/0x1ce
> > > [65611.886737]  [<ffffffff802b7962>] ? sys_splice+0x1b0/0x23e
> > > [65611.886737]  [<ffffffff8020bd9a>] ? system_call_after_swapgs+0=
x8a/0x8f
> > > [65611.886737]
> > > [65611.886737]
> > > [65611.886737] Code: 00 00 00 f6 44 10 0d 01 0f 85 67 ff ff ff 41=
 ff 4f
> > > 10 48 89 df 48 8b 43 08 48 8b 13 48 c7 43 08 00 00 00 00 48 c7 03=
 00 00
> > > 00 00 <48> 89 42 08 48 89 10 e8 ab 1b fd ff 48 8b 44 24 08 48 83 =
78 08
> > > [65611.886737] RIP  [<ffffffff803db40d>] tcp_read_sock+0xec/0x1a3
> > > [65611.886737]  RSP <ffff81006db59e68>
> > > [65611.886737] CR2: 0000000000000008
> > > [65611.886774] ---[ end trace 8f47273d77faf3c8 ]---
> > > ---Kernel having fun---
>=20
>=20

