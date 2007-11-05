From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc1: hangs when logging in to X session
Date: Mon, 5 Nov 2007 01:03:08 -0800
Message-ID: <20071105010308.6bd33fb1.akpm@linux-foundation.org>
References: <fg4qau$9mg$1@ger.gmane.org>
	<fg4tbq$kum$1@ger.gmane.org>
	<20071101163138.382e249b.akpm@linux-foundation.org>
	<200711050955.32881.marcus@better.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Marcus Better <marcus@better.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44493 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753313AbXKEJEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 04:04:12 -0500
In-Reply-To: <200711050955.32881.marcus@better.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Nov 2007 09:55:32 +0100 Marcus Better <marcus@better.se> wrote:

> Andrew Morton wrote:
> > > My laptop hangs when I try to log in to X with the current git kernel
> > > (commit 2a397e82c7db18019e408f953dd58dc1963a328c). It runs fine with
> > > 2.6.23. At boot time kdm starts normally, but hangs with the caps lock
> > > LED blinking immediately after I press Enter after typing the password.
> > >
> > > I can log in with a virtual console but didn't do much testing otherwise.
> > >
> > > The system is a Thinkpad R60, Intel Core 2 Duo, x86_64 running Debian.
> > > Kernel config is attached. A notable change in my config is that I
> > > enabled NO_HZ. I will try without it...
> >
> > hanging-with-led-blinking means the kernel oopsed.
> >
> > Please configure netconsole (Documentation/networking/netconsole.txt) and
> > see if you can capture the oops on another machine on the LAN.
> 
> Here it is.

Wonderful, thanks.

Suitable cc's added...

> Seems to be related to IPSEC - in fact the login process on my 
> system will trigger a network access over the VPN, and I also got a similar 
> crash without X shortly after starting the IPSEC tunnel.
> 
> general protection fault: 0000 [1] PREEMPT SMP
> CPU 0
> Modules linked in: xfrm4_mode_tunnel xfrm_user xfrm4_tunnel af_key netconsole 
> i915 drm rfcomm l2cap tunnel4 ipcomp esp4 ah4 nfsd exportfs autofs4 
> cpufreq_conservative cpufreq_userspace cpufreq_stats cpufreq_powersave 
> rpcsec_gss_krb5 auth_rpcgss nfs lockd nfs_acl sunrpc ipv6 deflate 
> zlib_deflate twofish_x86_64 twofish_common camellia serpent blowfish 
> des_generic xcbc sha1_generic crypto_null hmac crypto_hash fuse nls_utf8 ntfs 
> xfs coretemp cpufreq_ondemand acpi_cpufreq freq_table snd_seq_dummy 
> snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq 
> snd_seq_device mousedev arc4 ecb snd_hda_intel snd_pcm_oss snd_mixer_oss 
> pcmcia iwl3945 snd_pcm firmware_class snd_timer hci_usb snd serio_raw hwmon 
> mac80211 bluetooth soundcore yenta_socket rsrc_nonstatic pcmcia_core video 
> backlight output evdev psmouse i2c_i801 button nvram rtc iTCO_wdt pcspkr 
> snd_page_alloc cfg80211 ext3 jbd mbcache sha256_generic aes_x86_64 
> aes_generic cbc blkcipher dm_crypt dm_mirror dm_snapshot dm_mod firewire_ohci 
> firewire_core ehci_hcd uhci_hcd crc_itu_t usbcore tg3 sr_mod cdrom sd_mod 
> thermal processor fan
> Pid: 4347, comm: dnsmasq Not tainted 2.6.24-rc1-melech #4
> RIP: 0010:[<ffffffff880d3052>]  [<ffffffff880d3052>] :cbc:xor_128+0x2/0x20
> RSP: 0018:ffff8100049fd930  EFLAGS: 00010287
> RAX: 000000000e502390 RBX: 0000000000000010 RCX: ffff810009f7ac00
> RDX: 0000000000000010 RSI: ffff810009c48e10 RDI: 6ddaa59200000644
> RBP: 00000000fffffff0 R08: ffff81000a4a9ec0 R09: 0000000000000000
> R10: 000000004fa99cad R11: 0000000000000014 R12: 0000000000000010
> R13: ffffffff880df710 R14: 6ddaa59200000644 R15: 0000000000000040
> FS:  00002b29576ca6e0(0000) GS:ffffffff80590000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00002b898db23bc0 CR3: 0000000004a79000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process dnsmasq (pid: 4347, threadinfo ffff8100049fc000, task 
> ffff81000404b7e0)
> Stack:  ffffffff880d3488 ffff810000000000 ffff8100049fda48 ffff810009f7ac00
>  ffffffff880d3050 bd42b9d15e8c4d52 dc7227cd8329fa6a 0000000000000000
>  6ddaa59200000644 0000000000000000 6ddaa59200000644 ffff81000a4a9ec0
> Call Trace:
>  [<ffffffff880d3488>] :cbc:crypto_cbc_encrypt+0x148/0x180
>  [<ffffffff880d3050>] :cbc:xor_128+0x0/0x20
>  [<ffffffff88570bdd>] :esp4:esp_output+0x28d/0x470
>  [<ffffffff80483e3b>] csum_partial_copy_from_user+0x6b/0xf0
>  [<ffffffff80476dc1>] xfrm_output+0xf1/0x240
>  [<ffffffff8046d458>] xfrm4_output_finish2+0x78/0x230
>  [<ffffffff804313d6>] ip_push_pending_frames+0x2d6/0x510
>  [<ffffffff80433170>] ip_generic_getfrag+0x0/0x90
>  [<ffffffff80452515>] udp_push_pending_frames+0x145/0x390
>  [<ffffffff80453a27>] udp_sendmsg+0x337/0x750
>  [<ffffffff803fcd2b>] sock_sendmsg+0x12b/0x140
>  [<ffffffff803fcbea>] sock_recvmsg+0x14a/0x160
>  [<ffffffff8024fed0>] autoremove_wake_function+0x0/0x30
>  [<ffffffff803fde57>] move_addr_to_user+0x97/0xb0
>  [<ffffffff80486e71>] _read_unlock+0x11/0x40
>  [<ffffffff8040b890>] dev_ioctl+0x100/0x5c0
>  [<ffffffff803fdb76>] sys_sendto+0x146/0x1b0
>  [<ffffffff803fbfad>] sock_ioctl+0xed/0x260
>  [<ffffffff802adc4f>] do_ioctl+0x2f/0xa0
>  [<ffffffff8020c41e>] system_call+0x7e/0x83
> 
> 
> Code: 31 07 8b 46 04 31 47 04 8b 46 08 31 47 08 8b 46 0c 31 47 0c
> RIP  [<ffffffff880d3052>] :cbc:xor_128+0x2/0x20
>  RSP <ffff8100049fd930>
> Kernel panic - not syncing: Aiee, killing interrupt handler!
> 
> 
> Thanks,
> 
> Marcus
