From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: [Bugme-new] [Bug 12969] New: WARNING: at lib/dma-debug.c:539
	check_sync+0xe9/0x341() (Not tainted)
Date: Fri, 3 Apr 2009 11:57:54 +0200
Message-ID: <20090403095754.GB22472@amd.com>
References: <bug-12969-10286@http.bugzilla.kernel.org/> <20090401165015.8481f9e0.akpm@linux-foundation.org> <1238725419.17093.21.camel@segulix>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, zambrano@broadcom.com,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Sergio Monteiro Basto <sergio@sergiomb.no-ip.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa4ehsobe003.messaging.microsoft.com ([216.32.181.13]:36654
	"EHLO WA4EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751416AbZDCKMq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2009 06:12:46 -0400
Content-Disposition: inline
In-Reply-To: <1238725419.17093.21.camel@segulix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 03, 2009 at 03:23:39AM +0100, Sergio Monteiro Basto wrote:
> > > ------------[ cut here ]------------                             =
              =20
> > > WARNING: at lib/dma-debug.c:539 check_sync+0xe9/0x341() (Not tain=
ted)          =20
> > > Hardware name: HP Compaq nx6110 (PY501EA#AB9)                    =
              =20
> > > b44 0000:02:0e.0: DMA-API: device driver tries to sync DMA memory=
 it has not
> > > allocated [device address=3D0x0000000075941040] [size=3D1566 byte=
s] =20
> > > Modules linked in: llc bnep l2cap bluetooth autofs4 lm90 hwmon i2=
c_i801 sunrpc
> > > ipv6 cpufreq_ondemand acpi_cpufreq uinput snd_intel8x0m snd_intel=
8x0
> > > snd_ac97_codec snd_seq_dummy ac97_bus snd_seq_oss snd_seq_midi_ev=
ent snd_seq
> > > snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm b44 ssb firewire=
_ohci
> > > snd_timer ipw2200 iTCO_wdt mii firewire_core snd iTCO_vendor_supp=
ort libipw
> > > yenta_socket crc_itu_t lib80211 rsrc_nonstatic soundcore snd_page=
_alloc joydev
> > > pcspkr wmi serio_raw ata_generic pata_acpi i915 drm i2c_algo_bit =
i2c_core video
> > > output [last unloaded: scsi_wait_scan]                           =
              =20
> > > Pid: 2418, comm: S58ntpd Not tainted 2.6.29-16.fc10.i686.PAE #1  =
              =20
> > > Call Trace:                                                      =
              =20
> > >  [<c04396d1>] warn_slowpath+0x7c/0xbd                            =
              =20
> > >  [<c0457fe1>] ? register_lock_class+0x17/0x290                   =
              =20
> > >  [<c0458d61>] ? mark_lock+0x1e/0x349                             =
              =20
> > >  [<c0556448>] ? _raw_spin_unlock+0x74/0x78                       =
              =20
> > >  [<c0458d61>] ? mark_lock+0x1e/0x349                             =
              =20
> > >  [<c055a060>] ? check_sync+0x37/0x341                            =
              =20
> > >  [<c055a112>] check_sync+0xe9/0x341                              =
              =20
> > >  [<c0711245>] ? _spin_unlock_irqrestore+0x45/0x55                =
              =20
> > >  [<c04592db>] ? trace_hardirqs_on+0xb/0xd                        =
              =20
> > >  [<c055a4d1>] debug_dma_sync_single_for_device+0x2f/0x39         =
              =20
> > >  [<f828f722>] dma_sync_single_for_device+0x4a/0x59 [b44]         =
              =20
> > >  [<f828f76f>] ssb_dma_sync_single_for_device+0x3e/0x48 [b44]     =
              =20
> > >  [<f8291d1e>] b44_recycle_rx+0x18c/0x196 [b44]                   =
              =20
> > >  [<f8291f9f>] b44_poll+0x277/0x3c0 [b44]                         =
              =20
> > >  [<c0687bb9>] net_rx_action+0xa1/0x1ca                           =
              =20
> > >  [<c043e30a>] __do_softirq+0x9d/0x154                            =
              =20
> > >  [<c043e413>] do_softirq+0x52/0x7e                               =
              =20
> > >  [<c043e56f>] irq_exit+0x49/0x77                                 =
              =20
> > >  [<c040b22e>] do_IRQ+0x97/0xad                                   =
              =20
> > >  [<c0409dac>] common_interrupt+0x2c/0x34                         =
              =20
> >=20
> > This would appear to be reporting a bug in b44's DMA API usage. =20
>=20
> Hi!, are you saying that could be a bug in new DMA-API ? (if we have
> one)

We don't have a new DMA-API. I wrote a piece of code which checks if dr=
ivers
use the DMA-API as expected.

> I don't had problems before with this b44 and laptop is not new.

Most things we check for typically have no impact when there is no hard=
ware
IOMMU. The purpose of this debugging code is to find those bugs even wi=
thout an
hardware IOMMU in the system.

> With kernel 2.6.29, I am testing KMS on new drm/dri Intel video, I al=
so
> have one big warning with i915 reported on
> Bug 12419 - possible circular locking dependency on i915 dma.
>=20
> What I would like to know is : =20
> Could bug 12419 make this warning on b44 ? or could DMA-API make the =
2
> warnings ? or the 2 warnings are completed different ? and the
> combinations of this questions :)

It is hard to imagine that these two bugs have something to do with eac=
h other.
The bugzilla entry is a warning about a locking problem and the DMA-API
debugging code warns about wrong usage of the DMA-API.

	Joerg

--=20
           | Advanced Micro Devices GmbH
 Operating | Karl-Hammerschmidt-Str. 34, 85609 Dornach bei M=FCnchen
 System    |=20
 Research  | Gesch=E4ftsf=FChrer: Jochen Polster, Thomas M. McCoy, Giul=
iano Meroni
 Center    | Sitz: Dornach, Gemeinde Aschheim, Landkreis M=FCnchen
           | Registergericht M=FCnchen, HRB Nr. 43632

