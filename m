From: Borislav Petkov <bp@alien8.de>
Subject: Re: Kernel 4.8.7 crashing down cleanup_net()
Date: Sun, 13 Nov 2016 17:00:04 +0100
Message-ID: <20161113160004.vkmukwfoajlzhqu4@pd.tnic>
References: <CA+OSeu=TvXdd8VmxWOo2dh-jS_WrNibSWdCt0OEyPEkfxjO_yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Ashton Holmes <scoopta@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+OSeu=TvXdd8VmxWOo2dh-jS_WrNibSWdCt0OEyPEkfxjO_yw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hmm, there's cleanup_net() namespaces fun in there, adding netdev@.

On Sat, Nov 12, 2016 at 02:17:03PM -0800, Ashton Holmes wrote:
> I upgraded to 4.8.7 and the system boots and my root partition gets
> decrypted but right after that both of my monitors turn off and
> looking at syslog from 4.8.6 shows the following:
> 
> Nov 12 11:54:24 user-desktop kernel: [   19.853197] ------------[ cut
> here ]------------
> Nov 12 11:54:24 user-desktop kernel: [   19.853206] WARNING: CPU: 2
> PID: 177 at fs/proc/proc_sysctl.c:1607 ops_exit_list.isra.4+0x33/0x60
> Nov 12 11:54:24 user-desktop kernel: [   19.853210] Modules linked in:
> amdgpu eeepc_wmi i2c_algo_bit asus_wmi drm_kms_helper video rfkill
> snd_hda_codec_realtek ttm snd_hda_codec_generic snd_hda_codec_hdmi drm
> snd_hda_intel snd_usb_audio sparse_keymap snd_hda_codec mxm_wmi
> snd_usbmidi_lib snd_hda_core efi_pstore snd_hwdep snd_rawmidi evdev
> snd_seq_device joydev snd_pcm serio_raw pcspkr efivars fam15h_power
> k10temp snd_timer snd sp5100_tco i2c_piix4 sg soundcore i2c_core
> shpchp tpm_infineon tpm_tis tpm_tis_core tpm wmi button it87 hwmon_vid
> autofs4 ext4 crc16 jbd2 mbcache algif_skcipher af_alg dm_crypt dm_mod
> hid_generic usbhid hid sr_mod cdrom sd_mod ohci_pci crct10dif_pclmul
> crc32_pclmul crc32c_intel aesni_intel aes_x86_64 glue_helper lrw
> gf128mul ablk_helper cryptd psmouse ohci_hcd ahci libahci ehci_pci
> ehci_hcd libata xhci_pci xhci_hcd e1000e usbcore scsi_mod ptp
> usb_common pps_core
> Nov 12 11:54:24 user-desktop kernel: [   19.853264] CPU: 2 PID: 177
> Comm: kworker/u16:2 Not tainted 4.8.7 #1
> Nov 12 11:54:24 user-desktop kernel: [   19.853267] Hardware name: To
> be filled by O.E.M. To be filled by O.E.M./CROSSHAIR V FORMULA-Z, BIOS
> 2201 03/23/2015
> Nov 12 11:54:24 user-desktop kernel: [   19.853273] Workqueue: netns cleanup_net
> Nov 12 11:54:24 user-desktop kernel: [   19.853276]  0000000000000286
> 00000000b98071d2 ffffffff81302a8f 0000000000000000
> Nov 12 11:54:24 user-desktop kernel: [   19.853281]  0000000000000000
> ffffffff81076f54 ffff880814f88040 ffff8808140efdf0
> Nov 12 11:54:24 user-desktop kernel: [   19.853285]  ffffffff818f11d8
> ffffffff818f11e0 ffff8808140efde0 0000000000000200
> Nov 12 11:54:24 user-desktop kernel: [   19.853290] Call Trace:
> Nov 12 11:54:24 user-desktop kernel: [   19.853295]
> [<ffffffff81302a8f>] ? dump_stack+0x5c/0x7d
> Nov 12 11:54:24 user-desktop kernel: [   19.853299]
> [<ffffffff81076f54>] ? __warn+0xc4/0xe0
> Nov 12 11:54:24 user-desktop kernel: [   19.853302]
> [<ffffffff8149e243>] ? ops_exit_list.isra.4+0x33/0x60
> Nov 12 11:54:24 user-desktop kernel: [   19.853305]
> [<ffffffff8149f230>] ? cleanup_net+0x1b0/0x290
> Nov 12 11:54:24 user-desktop kernel: [   19.853309]
> [<ffffffff8108fefd>] ? process_one_work+0x14d/0x410
> Nov 12 11:54:24 user-desktop kernel: [   19.853312]
> [<ffffffff81090cc2>] ? worker_thread+0x62/0x490
> Nov 12 11:54:24 user-desktop kernel: [   19.853315]
> [<ffffffff81090c60>] ? rescuer_thread+0x340/0x340
> Nov 12 11:54:24 user-desktop kernel: [   19.853318]
> [<ffffffff81095f3f>] ? kthread+0xdf/0x100
> Nov 12 11:54:24 user-desktop kernel: [   19.853322]
> [<ffffffff8102b78b>] ? __switch_to+0x2bb/0x710
> Nov 12 11:54:24 user-desktop kernel: [   19.853325]
> [<ffffffff815a371f>] ? ret_from_fork+0x1f/0x40
> Nov 12 11:54:24 user-desktop kernel: [   19.853328]
> [<ffffffff81095e60>] ? kthread_park+0x50/0x50
> Nov 12 11:54:24 user-desktop kernel: [   19.853331] ---[ end trace
> c4840b46b58dbe12 ]---
> 

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
