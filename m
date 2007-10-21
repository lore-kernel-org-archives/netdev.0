From: Coly Li <coyli@suse.de>
Subject: Re: PROBLEM: oops, Linus tree: 2.6.23-g4fa4d23f, BUG: unable to handle
 kernel NULL pointer dereference at virtual address 00000004
Date: Sun, 21 Oct 2007 13:16:32 +0800
Message-ID: <471AE0B0.4060600@suse.de>
References: <4719B727.7090908@oak.selfip.net>	 <Pine.LNX.4.64.0710201246540.18815@twin.jikos.cz> <3d8471ca0710200432h3607b0a0i9169884ebec3b940@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jikos@jikos.cz>, Dave Haywood <tla@oak.selfip.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@openvz.org>
To: Guillaume Chazarain <guichaz@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:56884 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbXJUFPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 01:15:11 -0400
In-Reply-To: <3d8471ca0710200432h3607b0a0i9169884ebec3b940@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guillaume Chazarain wrote:
>>> BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004
> 
> This should be fixed in recent git by
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=9b013e05e0289c190a53d78ca029e2f21c0e4485
> 
Maybe we encounter same condition, at least the symbol name is same -- sock_setsockopt.

This happens in kernel bootup and makes network can not work properly -- I can not connect to
internet the whole weekend. Same as you, I am not a network guy, I tried to understand what
happened, but it seems not so easy for me ^_^.

Here is the oops message:
[ 4327.550035] BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004
[ 4327.550047] printing eip: c02ad991 *pdpt = 0000000006062001 <1>*pde = 0000000000000000
[ 4327.550061] Oops: 0000 [#1] SMP
[ 4327.550071] Modules linked in: arc4 ieee80211_crypt_wep af_packet ip6t_LOG nf_conntrack_ipv6
xt_pkttype ipt_LOG xt_limit deflate zlib_deflate twofish twofish_common camellia serpent blowfish
des_generic cbc ecb geode_aes blkcipher aes_i586 aes_generic xcbc sha256_generic sha1_generic
crypto_null af_key snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device microcode ip6t_REJECT xt_tcpudp
ipt_REJECT xt_state iptable_mangle iptable_nat nf_nat iptable_filter ip6table_mangle
nf_conntrack_ipv4 nf_conntrack ip_tables ip6table_filter ip6_tables x_tables ipv6
cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq speedstep_lib loop dm_mod
pcmcia nsc_ircc parport_pc irda parport ipw2200 rtc_cmos ieee80211 yenta_socket rsrc_nonstatic
crc_ccitt pcmcia_core thinkpad_acpi hwmon nvram rtc_core ieee80211_crypt firmware_class snd_intel8x0
sdhci rtc_lib battery snd_intel8x0m snd_ac97_codec ac97_bus output ac mmc_core snd_pcm snd_timer snd
soundcore sr_mod i2c_i801 i2c_core iTCO_wdt button snd_page_alloc iTCO_vendor_support cdrom
intel_agp agpgart tg3 uinput sg ehci_hcd uhci_hcd sd_mod usbcore edd ext3 mbcache jbd fan ata_piix
ahci libata scsi_mod thermal processor
[ 4327.550286] CPU:    0
[ 4327.550288] EIP:    0060:[<c02ad991>]    Not tainted VLI
[ 4327.550291] EFLAGS: 00010282   (2.6.23-bigsmp-g4fa4d23f #6)
[ 4327.550305] EIP is at sk_filter_delayed_uncharge+0x1/0x23
[ 4327.550312] eax: c614f738   ebx: 00000000   ecx: 00000003   edx: 00000000
[ 4327.550319] esi: c60d97b0   edi: c614f738   ebp: c61e2ef8   esp: c61e2ec8
[ 4327.550326] ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
[ 4327.550333] Process dhclient (pid: 7024, ti=c61e2000 task=c61e5120 task.ti=c61e2000)
[ 4327.550338] Stack: c61e2ef8 c02adb57 00000002 00000001 c02adaff 00000068 c60d97c0 00000058
[ 4327.550356]        00000000 c614f738 c61e2f24 c65c63f0 c61e2f48 c029c87f c61e2fb0 c030642f
[ 4327.550374]        00000001 00000246 0000001a 8005000b fffffff2 8005000b c03042ae 8005000b
[ 4327.550391] Call Trace:
[ 4327.550396]  [<c010680b>] show_trace_log_lvl+0x1a/0x2f
[ 4327.550409]  [<c01068bb>] show_stack_log_lvl+0x9b/0xa3
[ 4327.550419]  [<c0106a7b>] show_registers+0x1b8/0x28a
[ 4327.550429]  [<c0106c58>] die+0x10b/0x1ee
[ 4327.550438]  [<c030679a>] do_page_fault+0x7d4/0x8b9
[ 4327.550449]  [<c0304b72>] error_code+0x72/0x80
[ 4327.550458]  [<c029c87f>] sock_setsockopt+0x46f/0x4c2
[ 4327.550469]  [<c029952a>] sys_setsockopt+0x5a/0x90
[ 4327.550478]  [<c029abba>] sys_socketcall+0x1e8/0x241
[ 4327.550486]  [<c0105112>] syscall_call+0x7/0xb
[ 4327.550495]  =======================
[ 4327.550499] Code: 43 4e 39 d3 0f 8c 36 fe ff ff 0f b7 44 d1 f8 83 e0 07 83 f8 06 0f 94 c0 0f b6
c0 48 83 e0 ea eb 05 b8 ea ff ff ff 5b 5e 5d c3 55 <8b> 4a 04 89 e5 8d 0c cd 10 00 00 00 90 29 88 cc
00 00 00 8d 42
[ 4327.550590] EIP: [<c02ad991>] sk_filter_delayed_uncharge+0x1/0x23 SS:ESP 0068:c61e2ec8





> HTH.
> 

