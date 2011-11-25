From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Fri, 25 Nov 2011 21:32:02 +0100
Message-ID: <1322253122.2550.3.camel@edumazet-laptop>
References: <4E7F4D45.7040902@wolke7.net>
	 <1316978632.4122.103.camel@deadeye> <4E82C0B5.1050902@wolke7.net>
	 <1317254171.4068.12.camel@deadeye>
	 <20111124044137.GA18262@elie.hsd1.il.comcast.net>
	 <4ECFE7A7.5070300@wolke7.net>
	 <20111125201936.GA26692@elie.hsd1.il.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org,
	Armin Kazmi <armin.kazmi@tu-dortmund.de>,
	Gerd <booster@wolke7.net>
To: Jonathan Nieder <jrnieder@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111125201936.GA26692@elie.hsd1.il.comcast.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 25 novembre 2011 =C3=A0 14:19 -0600, Jonathan Nieder a =C3=A9=
crit :
> Hi,
>=20
> Gerd writes[1]:
>=20
> > Today I installed the 3.1 kernel and did some testing by copying fi=
les
> > with samba.
> [...]
> > Now the CPU hangs during the interrupts:
> [...]
> > r8169 0000:02:00.0: eth0: link up
> > ------------[ cut here ]------------
> > WARNING: at [...]/net/core/dev.c:3827 net_rx_action+0xda/0x17e()
> >
> > Hardware name: CM-iAM/SBC-FITPC2i
> > Modules linked in: cpufreq_userspace cpufreq_conservative cpufreq_s=
tats nfsd lockd nfs_acl auth_rpcgss sunrpc speedstep_lib cpufreq_powers=
ave fuse ext2 coretemp acpi_cpufreq mperf loop arc4 snd_hda_codec_realt=
ek rt2800usb rt2800lib crc_ccitt rt2x00usb rt2x00lib mac80211 psb_gfx(C=
) snd_hda_intel cfg80211 snd_hda_codec drm_kms_helper i2c_isch drm snd_=
hwdep rfkill tpm_tis tpm tpm_bios lpc_sch mfd_core evdev snd_pcm snd_se=
q snd_timer snd_seq_device battery processor button psmouse snd pcspkr =
serio_raw ac i2c_algo_bit power_supply i2c_core soundcore snd_page_allo=
c video usbhid ext4 hid mbcache jbd2 crc16 sd_mod crc_t10dif ata_generi=
c uhci_hcd pata_sch libata ehci_hcd scsi_mod usbcore sdhci_pci sdhci r8=
169 mii thermal thermal_sys mmc_core [last unloaded: scsi_wait_scan]
> > Pid: 0, comm: swapper Tainted: G         C  3.1.0-1-686-pae #1
> > Call Trace:
> >  [<c1037698>] ? warn_slowpath_common+0x68/0x79
> >  [<c120d061>] ? net_rx_action+0xda/0x17e
> >  [<c10376b6>] ? warn_slowpath_null+0xd/0x10
> >  [<c120d061>] ? net_rx_action+0xda/0x17e
> >  [<c103c05d>] ? local_bh_enable+0x2/0x2
> >  [<c103c0f1>] ? __do_softirq+0x94/0x12f
> >  [<c103c05d>] ? local_bh_enable+0x2/0x2
> >  <IRQ>  [<c103c2e2>] ? irq_exit+0x32/0x80
> >  [<c100ca6e>] ? do_IRQ+0x65/0x76
> >  [<c12b2a30>] ? common_interrupt+0x30/0x38
> >  [<c103007b>] ? sched_debug_show+0x165/0xb17
> >  [<c118519b>] ? intel_idle+0xb9/0xde
> >  [<c11f54d2>] ? cpuidle_idle_call+0xcd/0x140
> >  [<c100aef1>] ? cpu_idle+0x86/0xaa
> >  [<c143e708>] ? start_kernel+0x32a/0x32f
> >  ---[ end trace 6d03368d0e01d4ae ]---
> >  r8169 0000:02:00.0: eth0: link up
> >  r8169 0000:02:00.0: eth0: link up
> >  r8169 0000:02:00.0: eth0: link up
> >  r8169 0000:02:00.0: eth0: link up
> [...]
> > If you need any more information or log files please send me a mail=
=2E
>=20
> This is
>=20
> 			work =3D n->poll(n, weight);
> [...]
> 		WARN_ON_ONCE(work > weight);
>=20
> From the same log:
>=20
> > [    1.478652] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> > [    1.478722] r8169 0000:02:00.0: PCI INT A -> GSI 16 (level, low)=
 -> IRQ 16
> > [    1.478779] r8169 0000:02:00.0: setting latency timer to 64
> > [    1.478850] r8169 0000:02:00.0: irq 40 for MSI/MSI-X
> [...]
> > [    1.509507] r8169 0000:02:00.0: eth0: RTL8168c/8111c at 0xf82c20=
00, 00:01:c0:08:aa:31, XID 1c4000c0 IRQ 40
> > [    1.509569] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> > [    1.509633] r8169 0000:03:00.0: PCI INT A -> GSI 17 (level, low)=
 -> IRQ 17
> > [    1.509691] r8169 0000:03:00.0: setting latency timer to 64
> > [    1.509765] r8169 0000:03:00.0: irq 41 for MSI/MSI-X
> > [    1.511188] r8169 0000:03:00.0: eth1: RTL8168c/8111c at 0xf82d00=
00, 00:01:c0:08:aa:32, XID 1c4000c0 IRQ 41
>=20
> From another log, using a kernel without pae support:
>=20
> > [  844.056012] BUG: soft lockup - CPU#0 stuck for 23s! [smbd:2770]
> [...]
> > [  872.056011] BUG: soft lockup - CPU#0 stuck for 23s! [smbd:2770]
> [...]
> > [  900.056011] BUG: soft lockup - CPU#0 stuck for 23s! [smbd:2770]
>=20
> Gerd previously was getting transmit queue timeouts with a v2.6.32-ba=
sed
> kernel; with Debian's 3.1.1-1 kernel, the system hangs instead.  See =
[1]
> for the details, including full logs.
>=20
> Thanks for keeping the r8169 driver well maintained.  Any ideas for
> tracking this down?
>=20
> Looking forward to your thoughts,
> Jonathan
>=20
> [1] http://bugs.debian.org/642911
> http://bugs.debian.org/cgi-bin/bugreport.cgi?msg=3D34;filename=3Ddmes=
g_20111125_kernel_3.1-pae.txt;att=3D2;bug=3D642911

rtl8169_rx_interrupt(..., budget) can return budget + 1 sometimes
because of :

                /* Work around for AMD plateform. */
                if ((desc->opts2 & cpu_to_le32(0xfffe000)) &&
                    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_05)) {
                        desc->opts2 =3D 0;
                        cur_rx++;
                }


Sorry, I wont patch this today, its black Friday, and David said to
patch submitters :

"stick to turkey and wine you're better at it"=20

:)
