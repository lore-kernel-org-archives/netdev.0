From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: e1000e mutex contention log spew on 2.6.27
Date: Tue, 18 Nov 2008 03:39:52 -0800
Message-ID: <1227008392.24207.5.camel@jtkirshe-mobile.jf.intel.com>
References: <1226986433.32373.5.camel@stinkpad>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: "Jeffrey W. Baker" <jwbaker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:58977 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbYKRLlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 06:41:42 -0500
Received: by rv-out-0506.google.com with SMTP id k40so2883578rvb.1
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 03:41:41 -0800 (PST)
In-Reply-To: <1226986433.32373.5.camel@stinkpad>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-17 at 21:33 -0800, Jeffrey W. Baker wrote:
> I have a huge number of these log entries on a ThinkPad X61 (82566MM
> rev 03).  My system is generating one every two seconds.  Here's the
> first one, which contains a substantial amount of spurious memory
> contents:
> 
> WARNING: at /build/buildd/linux-2.6.27/drivers/net/e1000e/ich8lan.c:403 e1000_acquire_swflag_ich8lan+0x47/0xd0 [e1000e]()
> e1000e mutex contention. Owned by pid -1
> Modules linked in: af_packet i915 drm rfcomm sco bridge stp bnep l2cap ppdev ipv6 container sbs sbshc wmi pci_slot acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_conservative cpufreq_userspace cpufreq_ondemand freq_table iptable_filter ip_tables x_tables sbp2 parport_pc lp parport btusb bluetooth pcmcia arc4 ecb crypto_blkcipher thinkpad_acpi nvram evdev serio_raw psmouse pcspkr iwlagn iwlcore snd_hda_intel rfkill snd_pcm_oss snd_mixer_oss sdhci_pci battery sdhci led_class yenta_socket rsrc_nonstatic ac mac80211 snd_pcm mmc_core cfg80211 pcmcia_core video output snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd button intel_agp iTCO_wdt iTCO_vendor_support soundcore agpgart shpchp pci_hotplug snd_page_alloc ext3 jbd mbcache s
 d_mod crc_t10dif ata_generic sg pata_acpi ahci ata_piix ohci1394 libata ieee1394 scsi_mod ehci_hcd uhci_hcd usbcore dock e1000e thermal processor fan fbcon tileblit font bitblit soft
>  ursor fuse
> Pid: 5337, comm: NetworkManager Not tainted 2.6.27-7-generic #1
>  [<c0131d65>] warn_slowpath+0x65/0x90
>  [<c0123186>] ? set_next_entity+0x126/0x160
>  [<c0102df6>] ? __switch_to+0xa6/0x160
>  [<c01284cb>] ? finish_task_switch+0x2b/0xe0
>  [<c037c999>] ? schedule+0x429/0x790
>  [<c01376e6>] ? __do_softirq+0xf6/0x120
>  [<c037e511>] ? _spin_lock_irqs22 4.084550] etlink_e+] ]88iespeodod:x0cl]l4>  [link_rc f01?.e ect _0r-lxe12/
>  8551>] netl cb
>  Rlfpintis>80 c[ s+0x0/.085920018[=/ eeksth.8d00t]6n0/0x]  [<c001at- fbi _ie6s .
>  0<kgx30
>  [ 28816881.09k19cceet o_[a7cex
>  
>  .2n]  [<c04b0>] ?n0 ]ncp_meeu50f0i0x 0+0>[ 8880]  [<cre-[eccodci6?0e2fe]d n0x21/0x30.<4>[ 28/xie nuanvu M]]yq08[_<<+f75  [<c02e7sf0neds__1]]?0_eh>/ />k_smove_wact<40pa ipir1f3c_ e/>x>ockca>] ? >h0]bqysi  a1.[r0i7e200? a02edc151o 0eep_o1 23_0<<+xats2c01474b0>]02e66f1>+[/tfs h_[8  r]10?>22[_fy_>[ 28818 (seid_<030</1801eo0]10/02]  [<c6=idovoohm.6c0e c0vid3 <x3a/0x130
>  .102821nclcsde10 0x
>  o3e38ddmcimer_sta2f
>  80nti_af39e e0o+l2cf+00imer_s2f
>  806eisac39e ee08.2n/e<rrtimer0x2f
>  <ai b_mfs0e
>  p8/_20[/. <[ 2881.184f7898 bepuri -b[l0t0p[ ac20t e0
>  [ 28861db9484: ewcOc17? 24c]0 [fd[7[_2[8> 63--
>  <4 lg_6 te0080 8/b>] 1000eopmm1711e f[.x] syse00e/_pcadl/1c]2 8 < cd in: sfs h[>e>>>6> d--1
>  <ccih 08q_rp: c>3_ ek 51 _cpsmousq _08 20 0e0
>  _tablcled_ctg1xc8h4a_[8_c]dreq_taci lee4[8s8ieddf8py8e psnd_sed f<_ x[
>  r[ diro_rmidi si+k1[0]efk
>  o0c snd_miinte 8?f0>0_ivideoic]8127d[5 0 _Ob4_l_agp cx20s1l147 =ertpic sg c]w0e00c<c0_._nC ilebll0n41
>  _13<00erpage_allomm: N10c[+7 1 a +4epcnp uhcih0115<._35?>cel_aNetwo55.610_4l0m2itci ata_g5]  9[8[ .22nu2c/qhege56028f 8<8l
>  .1candid
>  253ea1 _9ee0c 0c8aaepi<c01310x40 >8
>  ]c4/21.>aamc_] ?1 frfe]2_] ]>pq[   eeend? co-lai< 80[   [< ee>xlcsqr41x0ke<0 _] ? c]?-codaG7x4ecx0>_e] ? 8lccida 00/00 4tendmsg? cop stmbrc 9u7e_[5_   [<c04eveai  n8ec] t_s] ? c0<eedor[5398110eendmsg+0xef/0x120
>  [<c0234775>] ? apparmor_socket_recvmsg+0x15/0x20
>  [<c01474b0>] ? autoremove_wake_function+0x0/0x50
>  [<c01474b0>] ? autoremove_wake_function+0x0/0x50
>  [<c02548ca>] ? copy_from_user+0x3a/0x130
>  [<c02edc15>] ? verify_iovec+0x35/0xb0
>  [<c02e66f1>] sys_sendmsg+0x111/0x230
>  [<c014b474>] ? hrtimer_start+0xc4/0x1c0
>  [<c01284cb>] ? finish_task_switch+0x2b/0xe0
>  [<c037c999>] ? schedule+0x429/0x790
>  [<c02e6edb>] sys_socketcall+0xeb/0x2d0
>  [<c0103f7b>] sysenter_do_call+0x12/0x2f
>  =======================
> ---[ end trace 1aa61db9484f7898 ]---
> 
> That's pretty sexy.  I hope I didn't lose any hardware here.  Both
> LEDs on the NIC are on steady.  Later log entries seem more sane I
> guess:
> 
> WARNING: at /build/buildd/linux-2.6.27/drivers/net/e1000e/ich8lan.c:403 e1000_acquire_swflag_ich8lan+0x47/0xd0 [e1000e]()
> e1000e mutex contention. Owned by pid -1
> Modules linked in: af_packet i915 drm rfcomm sco bridge stp bnep l2cap ppdev ipv6 container sbs sbshc wmi pci_slot acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_conservative cpufreq_userspace cpufreq_ondemand freq_table iptable_filter ip_tables x_tables sbp2 parport_pc lp parport btusb bluetooth pcmcia arc4 ecb crypto_blkcipher thinkpad_acpi nvram evdev serio_raw psmouse pcspkr iwlagn iwlcore snd_hda_intel rfkill snd_pcm_oss snd_mixer_oss sdhci_pci battery sdhci led_class yenta_socket rsrc_nonstatic ac mac80211 snd_pcm mmc_core cfg80211 pcmcia_core video output snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd button intel_agp iTCO_wdt iTCO_vendor_support soundcore agpgart shpchp pci_hotplug snd_page_alloc ext3 jbd mbcache s
 d_mod crc_t10dif ata_generic sg pata_acpi ahci ata_piix ohci1394 libata ieee1394 scsi_mod ehci_hcd uhci_hcd usbcore dock e1000e(-) thermal processor fan fbcon tileblit font bitblit s
>  ftcursor fuse
> Pid: 8697, comm: modprobe Tainted: G        W 2.6.27-7-generic #1
>  [<c0131d65>] warn_slowpath+0x65/0x90
>  [<c037c999>] ? schedule+0x429/0x790
>  [<c01376e6>] ? __do_softirq+0xf6/0x120
>  [<c0253dde>] ? delay_tsc+0xe/0x70
>  [<f8856028>] ? fuse_dev_fasync+0x28/0x40 [fuse]
>  [<c0253ea1>] ? __const_udelay+0x31/0x40
>  [<f88c243c>] ? e1000_flash_cycle_ich8lan+0x4c/0x70 [e1000e]
>  [<c037d3f9>] ? mutex_trylock+0x9/0x30
>  [<f88c2c17>] e1000_acquire_swflag_ich8lan+0x47/0xd0 [e1000e]
>  [<f88c7502>] e1000e_write_phy_reg_igp+0x22/0x70 [e1000e]
>  [<f88c2932>] e1000_phy_hw_reset_ich8lan+0x182/0x1b0 [e1000e]
>  [<f88d2c10>] e1000_remove+0xc8/0xca [e1000e]
>  [<c02630be>] pci_device_remove+0x1e/0x40
>  [<c02c3a19>] __device_release_driver+0x79/0xc0
>  [<c02c3aff>] driver_detach+0x9f/0xb0
>  [<c02c2d1b>] bus_remove_driver+0x7b/0xb0
>  [<c02c4009>] driver_unregister+0x39/0x40
>  [<c02632e9>] pci_unregister_driver+0x29/0x80
>  [<c0144fb0>] ? wakeme_after_rcu+0x0/0x20
>  [<f88d2b37>] e1000_exit_module+0x12/0x23 [e1000e]
>  [<c015ad07>] sys_delete_module+0x167/0x230
>  [<c0199d7a>] ? do_munmap+0x1da/0x230
>  [<c014ba38>] ? up_write+0x8/0x20
>  [<c0103f7b>] sysenter_do_call+0x12/0x2f
>  [<c0370000>] ? default_device_exit+0x60/0xb0
>  =======================
> ---[ end trace 1aa61db9484f7898 ]---
> 
> I removed e1000e and now the system is acting in the usual way again.
> 
> -jwb

Please send your kernel config.  It appears that you are running 2.6.27,
is that correct?  Have you tried the latest stable version of the kernel
(2.6.27.6)?

-- 
Cheers,
Jeff

