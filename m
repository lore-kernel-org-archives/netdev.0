From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: RFC: Reproducible oops with lockdep on count_matching_names()
Date: Mon, 05 Nov 2007 13:00:16 +0100
Message-ID: <1194264016.27652.428.camel@twins>
References: <20071101191716.GA3201@pogo> <1194001120.27652.353.camel@twins>
	 <43e72e890711031258g4ccd9cd0hc4520e9473f6ce49@mail.gmail.com>
	 <200711032106.56569.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200711032106.56569.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-11-03 at 21:06 +0100, Michael Buesch wrote:
> On Saturday 03 November 2007 20:58:09 Luis R. Rodriguez wrote:
> > I was using SLAB and ran into other strange oops, as the one below,
> > but after switching to SLUB, after Michael Buesch's suggestion that
> > one went away... The lockdep segfault is still present, however.
> 
> Who is responsible for slab btw?
> I mean, someone should be interested in getting this bug fixed. :)
> When using slab I see random corruptions. I think related to rmmod, but
> I'm not sure. I don't see this with slub.

Pekka and Christoph do most SLAB work.

the snipped oops:

> ----- oops with slab, not reproducible with slub:
> 
> mcgrof@pogo:~$ sudo rmmod tg3
> mcgrof@pogo:~$ sudo rmmod sr_mod
> 
> *** dmesg -c
> 
> ACPI: PCI interrupt for device 0000:02:00.0 disabled
> BUG: unable to handle kernel paging request at virtual address f88a4a05
> printing eip: f88a4a05 *pde = 02000067 *pte = 00000000
> Oops: 0000 [#1]
> Modules linked in: sr_mod uinput thinkpad_acpi hwmon backlight nvram
> ipv6 acpi_cpufreq cpufreq_userspace cpufreq_powersave cpufreq_ondemand
> cpufreq_conservative dock arc4 ecb blkcipher cryptomgr crypto_algapi
> rc80211_simple ath5k mac80211 cfg80211 pcmcia crc32 snd_hda_intel
> snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_hwdep snd_seq_oss
> ipw2200 snd_seq_midi_event ieee80211 ieee80211_crypt sg ehci_hcd
> uhci_hcd yenta_socket rsrc_nonstatic snd_seq snd_timer snd_seq_device
> firmware_class cdrom pcmcia_core usbcore evdev rng_core rtc snd
> soundcore
> 
> Pid: 2908, comm: modprobe Not tainted (2.6.24-rc1 #18)
> EIP: 0060:[<f88a4a05>] EFLAGS: 00010086 CPU: 0
> EIP is at 0xf88a4a05
> EAX: c20b75c8 EBX: c2f86f38 ECX: f88a4a05 EDX: c2f86f38
> ESI: c20b75c8 EDI: c2f89c00 EBP: c3897bfc ESP: c3897be0
>  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> Process modprobe (pid: 2908, ti=c3896000 task=c3935150 task.ti=c3896000)
> Stack: c01b2afc c2f82d98 c3897bf4 c01ba8b6 c2f86f38 c20b75c8 c2f82c00 c3897c24
>        c02186dd c2f86f38 c3897c24 c01b54c0 c20b75c8 00000001 c20b75c8 c2f86f38
>        c20b75c8 c3897c30 c01b54ed 00000001 c3897c54 c01b556c 00000001 c3897cd4
> Call Trace:
>  [<c0104cec>] show_trace_log_lvl+0x1a/0x2f
>  [<c0104d9e>] show_stack_log_lvl+0x9d/0xa5
>  [<c0104e53>] show_registers+0xad/0x17c
>  [<c0105017>] die+0xf5/0x1c6
>  [<c0112715>] do_page_fault+0x450/0x537
>  [<c02a835a>] error_code+0x6a/0x70
>  [<c02186dd>] scsi_request_fn+0x5f/0x2ec
>  [<c01b54ed>] __generic_unplug_device+0x20/0x23
>  [<c01b556c>] blk_execute_rq_nowait+0x7c/0x8f
>  [<c01b69e5>] blk_execute_rq+0xb1/0xcf
>  [<c0217f53>] scsi_execute+0xc4/0xd7
>  [<c0218014>] scsi_execute_req+0xae/0xcb
>  [<f885f571>] sr_probe+0x1d5/0x557 [sr_mod]
>  [<c020fd33>] driver_probe_device+0xe8/0x168
>  [<c020fec9>] __driver_attach+0x6a/0xa1
>  [<c020f271>] bus_for_each_dev+0x36/0x5b
>  [<c020fb7f>] driver_attach+0x19/0x1b
>  [<c020f556>] bus_add_driver+0x73/0x1aa
>  [<c02100a5>] driver_register+0x67/0x6c
>  [<c021b4f8>] scsi_register_driver+0xf/0x11
>  [<f8863023>] init_sr+0x23/0x3d [sr_mod]
>  [<c013a461>] sys_init_module+0x1142/0x1262
>  [<c0103d7e>] sysenter_past_esp+0x5f/0xa5
>  =======================
> Code:  Bad EIP value.
> EIP: [<f88a4a05>] 0xf88a4a05 SS:ESP 0068:c3897be0
> 
