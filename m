From: "Mike ." <mike-bugreport@hotmail.com>
Subject: Bug#656476: Sundance network driver (D-Link DFE-580TX) timeouts rendering interface unusable
Date: Wed, 1 Feb 2012 15:42:12 +0100
Message-ID: <SNT141-W2773C07AA4E8276F3E1E4496730@phx.gbl>
References: <SNT141-W3553B2629FBBC84A5A140596860@phx.gbl>,<1327205171.8004.96.camel@deadeye>,<SNT141-W5087B9A5022955EA5564DB96890@phx.gbl>,<20120126220640.GO12704@decadent.org.uk>,<SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>,<1327811546.5400.291.camel@deadeye>,<CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>,<1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>,<1327932311.5400.429.camel@deadeye>,<1327933736.2288.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>,<1327934477.5400.448.camel@deadeye>,<1327935455.2297.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>,<1327936900.2297.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: "Mike ." <mike-bugreport@hotmail.com>, 656476@bugs.debian.org
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="_e1391b4c-ba8c-4197-8b54-fdd9b9330725_"
Cc: <kirjanov@gmail.com>, <656476@bugs.debian.org>, <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>, <ben@decadent.org.uk>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.656476.B656476.132810734017732@bugs.debian.org>
In-Reply-To: <1327936900.2297.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

--_e1391b4c-ba8c-4197-8b54-fdd9b9330725_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


> Oh well=2C we also must make sure we held np->lock in TX completion when
> doing our test to eventually call netif_wake_queue()=2C I missed it was
> released too early.
>=20
> here is a more complete patch.

I applied the patch=2C recompiled the module=2C loaded it into the kernel a=
nd started testing traffic on the interface with the following result :

[ 1124.008030] ------------[ cut here ]------------
[ 1124.008101] WARNING: at /build/buildd-linux-2.6_3.2.1-2-i386-4wAPNj/linu=
x-2.6-3.2.1/debian/build/source_i386_none/net/sched/sch_generic.c:255 dev_w=
atchdog+0xb1/0x104()
[ 1124.008201] Hardware name:
[ 1124.008252] NETDEV WATCHDOG: eth1 (sundance): transmit queue 0 timed out
[ 1124.008309] Modules linked in: sundance(O) p4_clockmod cpufreq_powersave=
 cpufreq_userspace cpufreq_conservative cpufreq_stats speedstep_lib mperf f=
use w83627ehf hwmon_vid coretemp loop ohci_hcd snd_intel8x0 snd_ac97_codec =
ehci_hcd ac97_bus snd_pcm usbcore snd_seq snd_timer snd_seq_device shpchp p=
smouse snd sis900 pci_hotplug serio_raw pcspkr mii evdev soundcore parport_=
pc snd_page_alloc parport processor tpm_tis tpm tpm_bios thermal_sys button=
 usb_common ext3 jbd mbcache sd_mod crc_t10dif ata_generic sata_sis pata_si=
s libata scsi_mod [last unloaded: sundance]
[ 1124.010147] Pid: 5122=2C comm: gnome-terminal Tainted: G           O 3.2=
.0-1-686-pae #1
[ 1124.010219] Call Trace:
[ 1124.010286]  [<c1038280>] ? warn_slowpath_common+0x68/0x79
[ 1124.010344]  [<c1229e38>] ? dev_watchdog+0xb1/0x104
[ 1124.010399]  [<c10382f9>] ? warn_slowpath_fmt+0x29/0x2d
[ 1124.010455]  [<c1229e38>] ? dev_watchdog+0xb1/0x104
[ 1124.010511]  [<c103ccb5>] ? local_bh_enable+0x2/0x2
[ 1124.010567]  [<c1041e78>] ? run_timer_softirq+0x150/0x1f3
[ 1124.010622]  [<c1229d87>] ? netif_tx_unlock+0x3a/0x3a
[ 1124.010678]  [<c103ccb5>] ? local_bh_enable+0x2/0x2
[ 1124.010733]  [<c103cd49>] ? __do_softirq+0x94/0x12f
[ 1124.010788]  [<c103ccb5>] ? local_bh_enable+0x2/0x2
[ 1124.010841]  <IRQ>  [<c103cf3a>] ? irq_exit+0x32/0x80
[ 1124.010931]  [<c101e6f4>] ? smp_apic_timer_interrupt+0x5b/0x65
[ 1124.012339]  [<c12b9b11>] ? apic_timer_interrupt+0x31/0x38
[ 1124.012397]  [<c12b007b>] ? set_cpu_sibling_map+0x200/0x250
[ 1124.012452] ---[ end trace d55b57d11770d7d5 ]---

After this the same repeat of transmit timeouts (as posted earlier) in the =
log untill I down the interface.

Mike.

 		 	   		  =

--_e1391b4c-ba8c-4197-8b54-fdd9b9330725_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<style><!--
.hmmessage P
{
margin:0px=3B
padding:0px
}
body.hmmessage
{
font-size: 10pt=3B
font-family:Tahoma
}
--></style></head>
<body class=3D'hmmessage'><div dir=3D'ltr'>
&gt=3B Oh well=2C we also must make sure we held np-&gt=3Block in TX comple=
tion when<br><div>&gt=3B doing our test to eventually call netif_wake_queue=
()=2C I missed it was<br>&gt=3B released too early.<br>&gt=3B <br>&gt=3B he=
re is a more complete patch.<br><br>I applied the patch=2C recompiled the m=
odule=2C loaded it into the kernel and started testing traffic on the inter=
face with the following result :<br><br>[ 1124.008030] ------------[ cut he=
re ]------------<br>[ 1124.008101] WARNING: at /build/buildd-linux-2.6_3.2.=
1-2-i386-4wAPNj/linux-2.6-3.2.1/debian/build/source_i386_none/net/sched/sch=
_generic.c:255 dev_watchdog+0xb1/0x104()<br>[ 1124.008201] Hardware name:<b=
r>[ 1124.008252] NETDEV WATCHDOG: eth1 (sundance): transmit queue 0 timed o=
ut<br>[ 1124.008309] Modules linked in: sundance(O) p4_clockmod cpufreq_pow=
ersave cpufreq_userspace cpufreq_conservative cpufreq_stats speedstep_lib m=
perf fuse w83627ehf hwmon_vid coretemp loop ohci_hcd snd_intel8x0 snd_ac97_=
codec ehci_hcd ac97_bus snd_pcm usbcore snd_seq snd_timer snd_seq_device sh=
pchp psmouse snd sis900 pci_hotplug serio_raw pcspkr mii evdev soundcore pa=
rport_pc snd_page_alloc parport processor tpm_tis tpm tpm_bios thermal_sys =
button usb_common ext3 jbd mbcache sd_mod crc_t10dif ata_generic sata_sis p=
ata_sis libata scsi_mod [last unloaded: sundance]<br>[ 1124.010147] Pid: 51=
22=2C comm: gnome-terminal Tainted: G&nbsp=3B&nbsp=3B&nbsp=3B&nbsp=3B&nbsp=
=3B&nbsp=3B&nbsp=3B&nbsp=3B&nbsp=3B&nbsp=3B O 3.2.0-1-686-pae #1<br>[ 1124.=
010219] Call Trace:<br>[ 1124.010286]&nbsp=3B [&lt=3Bc1038280&gt=3B] ? warn=
_slowpath_common+0x68/0x79<br>[ 1124.010344]&nbsp=3B [&lt=3Bc1229e38&gt=3B]=
 ? dev_watchdog+0xb1/0x104<br>[ 1124.010399]&nbsp=3B [&lt=3Bc10382f9&gt=3B]=
 ? warn_slowpath_fmt+0x29/0x2d<br>[ 1124.010455]&nbsp=3B [&lt=3Bc1229e38&gt=
=3B] ? dev_watchdog+0xb1/0x104<br>[ 1124.010511]&nbsp=3B [&lt=3Bc103ccb5&gt=
=3B] ? local_bh_enable+0x2/0x2<br>[ 1124.010567]&nbsp=3B [&lt=3Bc1041e78&gt=
=3B] ? run_timer_softirq+0x150/0x1f3<br>[ 1124.010622]&nbsp=3B [&lt=3Bc1229=
d87&gt=3B] ? netif_tx_unlock+0x3a/0x3a<br>[ 1124.010678]&nbsp=3B [&lt=3Bc10=
3ccb5&gt=3B] ? local_bh_enable+0x2/0x2<br>[ 1124.010733]&nbsp=3B [&lt=3Bc10=
3cd49&gt=3B] ? __do_softirq+0x94/0x12f<br>[ 1124.010788]&nbsp=3B [&lt=3Bc10=
3ccb5&gt=3B] ? local_bh_enable+0x2/0x2<br>[ 1124.010841]&nbsp=3B &lt=3BIRQ&=
gt=3B&nbsp=3B [&lt=3Bc103cf3a&gt=3B] ? irq_exit+0x32/0x80<br>[ 1124.010931]=
&nbsp=3B [&lt=3Bc101e6f4&gt=3B] ? smp_apic_timer_interrupt+0x5b/0x65<br>[ 1=
124.012339]&nbsp=3B [&lt=3Bc12b9b11&gt=3B] ? apic_timer_interrupt+0x31/0x38=
<br>[ 1124.012397]&nbsp=3B [&lt=3Bc12b007b&gt=3B] ? set_cpu_sibling_map+0x2=
00/0x250<br>[ 1124.012452] ---[ end trace d55b57d11770d7d5 ]---<br><br>Afte=
r this the same repeat of transmit timeouts (as posted earlier) in the log =
untill I down the interface.<br><br>Mike.<br><br></div> 		 	   		  </div></=
body>
</html>=

--_e1391b4c-ba8c-4197-8b54-fdd9b9330725_--
