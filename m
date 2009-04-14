From: Mariusz Kozlowski <m.kozlowski-NWF1p15JEu3VItvQsEIGlw@public.gmane.org>
Subject: Re: panic on rmmod of nf_conntrack_irc
Date: Tue, 14 Apr 2009 22:06:57 +0200
Message-ID: <20090414220657.1174e60e@mako-desktop>
References: <20090410191736.21efab8c@mako-desktop>
	<49E4744D.5090205@trash.net>
	<49E47C2D.1050508@cosmosbay.com>
	<49E47EA5.3060706@trash.net>
	<20090414211946.4ea0455e@mako-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netfilter Development Mailinglist
	<netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mariusz Kozlowski <m.kozlowski-NWF1p15JEu3VItvQsEIGlw@public.gmane.org>,
	bart.de.schuymer-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org, ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090414211946.4ea0455e@mako-desktop>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Apr 2009 21:19:46 +0200
Mariusz Kozlowski <m.kozlowski-NWF1p15JEu3VItvQsEIGlw@public.gmane.org> wrote:

> On Tue, 14 Apr 2009 14:16:37 +0200
> Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org> wrote:
>=20
> > Eric Dumazet wrote:
> > > Patrick McHardy a =C3=A9crit :
> > >> Mariusz Kozlowski wrote:
> > >>>     netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get ri=
d of
> > >>> call_rcu()
> > >> Thanks for the report. Does this patch fix it?
> > >>
> > >=20
> > > Hi Patrick, sorry for the delay, I was in holidays.
> >=20
> > No problem, me too :)
> >=20
> > > I should have used different fields names (from "next", "first", =
=2E..) to catch this
> > > kind of errors at compile time :(
> >  >
> > > Something like :
> >=20
> > Thanks Eric. I guess at this point it doesn't really matter anymore
> > for the upstream kernel, but I'll apply your patch after getting
> > confirmation from Mariusz to make sure that people maintaining
> > external patches will notice the change (and won't send me broken
> > patches :)).
>=20
> Ok good. It doesn't panic now on nf_conntrack_irc rmmod

So feel free to add my rb and tb lines to it :)

> but I found another bug.
> Now it's NULL pointer dereference I when doing rmmod of ebt_log. To r=
eproduce simply:
>=20
> # modprobe ebt_log && rmmod ebt_log
>=20
> This is from the mainline kernel + your (Erics) patch:
>=20
> BUG: unable to handle kernel NULL pointer dereference at 000000000000=
0008
> IP: [<ffffffff8048490a>] nf_log_unregister+0x2a/0x90
> PGD 6f0e8067 PUD 6a2e0067 PMD 0=20
> Oops: 0002 [#1] PREEMPT SMP=20
> last sysfs file: /sys/devices/LNXSYSTM:00/device:00/PNP0A08:00/device=
:01/PNP0C09:00/PNP0C0A:00/power_supply/BAT0/energy_full
> CPU 0=20
> Modules linked in: ebt_log(-) nfs lockd auth_rpcgss sunrpc netconsole=
 af_packet i915 drm i2c_algo_bit i2c_core kvm_intel kvm ppdev acpi_cpuf=
req cpufreq_stats cpufreq_powersave cpufreq_userspace cpufreq_conservat=
ive cpufreq_ondemand freq_table fan sbs sbshc container pci_slot iptabl=
e_filter ip_tables x_tables sbp2 lp fuse snd_hda_codec_analog arc4 ecb =
snd_hda_intel snd_hda_codec snd_pcm_oss snd_mixer_oss iwl3945 iwlcore t=
hinkpad_acpi sr_mod cdrom pcmcia mac80211 snd_pcm rfkill led_class snd_=
seq_dummy snd_seq_oss snd_seq_midi_event evdev thermal uhci_hcd ehci_hc=
d parport_pc ohci1394 nvram yenta_socket rsrc_nonstatic pcmcia_core snd=
_seq pcspkr psmouse serio_raw usbcore cfg80211 e1000e ieee1394 sg parpo=
rt battery ac button processor snd_timer snd_seq_device intel_agp snd s=
oundcore snd_page_alloc
> Pid: 10249, comm: rmmod Not tainted 2.6.30-rc1-00204-gb0cbc86-dirty #=
33 7667Y24
> RIP: 0010:[<ffffffff8048490a>]  [<ffffffff8048490a>] nf_log_unregiste=
r+0x2a/0x90
> RSP: 0018:ffff88006a331ec8  EFLAGS: 00010207
> RAX: 0000000000000000 RBX: ffffffffa02d1d00 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffffffff8065bb80
> RBP: ffff88006a331ed8 R08: 0000000000000002 R09: ffffffff80676600
> R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> R13: 0000000000000880 R14: 0000000000000000 R15: 0000000000000000
> FS:  0000000000000000(0000) GS:ffff880001010000(0063) knlGS:00000000f=
7fc46b0
> CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
> CR2: 0000000000000008 CR3: 000000006f9f9000 CR4: 00000000000026a0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process rmmod (pid: 10249, threadinfo ffff88006a330000, task ffff8800=
6f3c8000)
> Stack:
>  ffffffffa02d1e80 ffffffffa02d1e80 ffff88006a331ee8 ffffffffa02d1518
>  ffff88006a331f78 ffffffff8026ddbb 00676f6c5f746265 ffffffff80229e77
>  0000000000000282 ffff88006a331f58 ffff88006f3c8000 0000000000000000
> Call Trace:
>  [<ffffffffa02d1518>] ebt_log_fini+0x10/0x1e [ebt_log]
>  [<ffffffff8026ddbb>] sys_delete_module+0x18b/0x240
>  [<ffffffff80229e77>] ? do_page_fault+0x187/0x2a0
>  [<ffffffff8022f08b>] sysenter_dispatch+0x7/0x32
> Code: 90 55 48 89 e5 53 48 89 fb 48 83 ec 08 48 c7 c7 80 bb 65 80 e8 =
78 a9 06 00 31 c9 eb 31 0f 1f 40 00 48 8b 54 4b 18 48 8b 44 4b 20 <48> =
89 42 08 48 89 10 48 c7 44 4b 20 00 02 20 00 48 c7 44 4b 18=20
> RIP  [<ffffffff8048490a>] nf_log_unregister+0x2a/0x90
>  RSP <ffff88006a331ec8>
> CR2: 0000000000000008
>=20
> If this is not related or you don't have a clue I can bisect it.

The same happens for ebt_ulog on clean latest mainline (as of 6f66cbc6)
so just for reference:

BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
08
IP: [<ffffffff80484b4a>] nf_log_unregister+0x2a/0x90
PGD 6f0ff067 PUD 6fb1a067 PMD 0=20
Oops: 0002 [#1] PREEMPT SMP=20
last sysfs file: /sys/devices/LNXSYSTM:00/device:00/PNP0A08:00/device:0=
1/PNP0C09:00/PNP0C0A:00/power_supply/BAT0/energy_full
CPU 1=20
Modules linked in: ebt_ulog(-) netconsole af_packet i915 drm i2c_algo_b=
it i2c_core kvm_intel kvm ppdev acpi_cpufreq cpufreq_stats cpufreq_powe=
rsave cpufreq_userspace cpufreq_conservative cpufreq_ondemand freq_tabl=
e fan sbs sbshc container pci_slot iptable_filter ip_tables x_tables sb=
p2 lp fuse snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_pcm_oss=
 snd_mixer_oss snd_pcm snd_seq_dummy arc4 snd_seq_oss ecb snd_seq_midi_=
event thinkpad_acpi pcmcia snd_seq rfkill sr_mod cdrom iwl3945 iwlcore =
mac80211 snd_timer snd_seq_device ehci_hcd uhci_hcd ohci1394 pcspkr led=
_class yenta_socket rsrc_nonstatic evdev parport_pc serio_raw psmouse i=
eee1394 sg nvram pcmcia_core parport ac battery cfg80211 processor ther=
mal button e1000e usbcore snd intel_agp soundcore snd_page_alloc
Pid: 4986, comm: rmmod Not tainted 2.6.30-rc1-00501-g6f66cbc #34 7667Y2=
4
RIP: 0010:[<ffffffff80484b4a>]  [<ffffffff80484b4a>] nf_log_unregister+=
0x2a/0x90
RSP: 0018:ffff88006f91deb8  EFLAGS: 00010203
RAX: 0000000000000000 RBX: ffffffffa038d580 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffffffff8065cc40
RBP: ffff88006f91dec8 R08: 0000000000000002 R09: ffffffff80677600
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000880 R14: 0000000000000000 R15: 0000000000000000
=46S:  0000000000000000(0000) GS:ffff880001029000(0063) knlGS:00000000f=
7f0b6b0
CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
CR2: 0000000000000008 CR3: 000000006f0ab000 CR4: 00000000000026a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rmmod (pid: 4986, threadinfo ffff88006f91c000, task ffff88006f1=
241a0)
Stack:
 ffff88006f91dee8 ffffffffa038d920 ffff88006f91dee8 ffffffffa038c6ca
 ffffffffa038d700 0000000000000000 ffff88006f91df78 ffffffff8026deab
 676f6c755f746265 ffffffff80229e00 0000000000000282 ffff88006f91df58
Call Trace:
 [<ffffffffa038c6ca>] ebt_ulog_fini+0x1a/0x7e [ebt_ulog]
 [<ffffffff8026deab>] sys_delete_module+0x18b/0x240
 [<ffffffff80229e00>] ? do_page_fault+0xd0/0x2a0
 [<ffffffff8022f12b>] sysenter_dispatch+0x7/0x32
Code: 90 55 48 89 e5 53 48 89 fb 48 83 ec 08 48 c7 c7 40 cc 65 80 e8 88=
 a9 06 00 31 c9 eb 31 0f 1f 40 00 48 8b 54 4b 18 48 8b 44 4b 20 <48> 89=
 42 08 48 89 10 48 c7 44 4b 20 00 02 20 00 48 c7 44 4b 18=20
RIP  [<ffffffff80484b4a>] nf_log_unregister+0x2a/0x90
 RSP <ffff88006f91deb8>
CR2: 0000000000000008

(adding Bart and ebtables-devel to cc)

	Mariusz
