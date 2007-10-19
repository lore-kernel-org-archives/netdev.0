From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: networking crash in current mainline:
 sk_filter_delayed_uncharge()
Date: Fri, 19 Oct 2007 20:05:54 +0200
Message-ID: <20071019200554.58c15ccb@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.drzeus.cx ([85.8.24.16]:54372 "EHLO smtp.drzeus.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762732AbXJSSF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 14:05:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:

> powerpc mac G5
> config: http://userweb.kernel.org/~akpm/config-g5.txt
> screenshot: http://userweb.kernel.org/~akpm/dsc00005.jpg
> 
> It does this shortly after bringing up eth0 (tg3), in dhclient.

+1

A Pentium M laptop here. Problem both with a ipw2200 wifi card and 8139
ethernet card.

[  174.237818] BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004
[  174.237828] printing eip: c05b6ed1 *pde = 00000000 
[  174.237834] Oops: 0000 [#1] PREEMPT 
[  174.237837] Modules linked in: tun rfcomm l2cap sunrpc binfmt_misc radeon drm ipv6 snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd hci_usb pcmcia ipw2200 soundcore button bluetooth rtc_cmos parport_pc smsc_ircc2 firewire_ohci i2c_i801 yenta_socket rsrc_nonstatic ieee80211 rtc_core 8139cp parport snd_page_alloc irda firewire_core crc_itu_t 8139too ieee80211_crypt battery ac pcmcia_core pcspkr i2c_core wbsd mmc_core video output rtc_lib crc_ccitt mii sr_mod sg cdrom ata_piix libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ehci_hcd
[  174.237880] CPU:    0
[  174.237881] EIP:    0060:[<c05b6ed1>]    Not tainted VLI
[  174.237882] EFLAGS: 00210246   (2.6.23 #11)
[  174.237892] EIP is at sk_filter_delayed_uncharge+0x1/0x20
[  174.237895] eax: c3cefc00   ebx: 00000000   ecx: 00000000   edx: 00000000
[  174.237898] esi: c3cefc00   edi: 00000000   ebp: c3e05efc   esp: c3e05edc
[  174.237901] ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
[  174.237904] Process dhclient (pid: 2997, ti=c3e05000 task=c3e753b0 task.ti=c3e05000)
[  174.237906] Stack: c3e05efc c05b7032 00000068 c3cf3080 00000058 c3e05f24 c3cefc00 c3a86300 
[  174.237913]        c3e05f48 c05a366e c3d039f8 c3e2c180 00000004 00000000 bfca000b 00000001 
[  174.237918]        bfca000b c3756080 bfca000b 080b3320 c3e05f5c c3e05f48 c059f2f0 c3e05f58 
[  174.237924] Call Trace:
[  174.237926]  [<c04051da>] show_trace_log_lvl+0x1a/0x30
[  174.237933]  [<c0405299>] show_stack_log_lvl+0xa9/0xd0
[  174.237937]  [<c04054c6>] show_registers+0x206/0x350
[  174.237940]  [<c0405711>] die+0x101/0x200
[  174.237944]  [<c060cd7e>] do_page_fault+0x3de/0x6c0
[  174.237950]  [<c060b402>] error_code+0x6a/0x70
[  174.237953]  [<c05a366e>] sock_setsockopt+0x58e/0x5b0
[  174.237958]  [<c059f4c5>] sys_setsockopt+0x95/0xb0
[  174.237964]  [<c05a0f8a>] sys_socketcall+0x21a/0x280
[  174.237968]  [<c040428a>] syscall_call+0x7/0xb
[  174.237972]  =======================
[  174.237973] Code: 77 c8 eb e6 8d b6 00 00 00 00 83 7c d9 04 0f 76 b9 eb d7 8d b4 26 00 00 00 00 8b 44 d9 04 85 c0 75 a8 eb c6 8d b6 00 00 00 00 55 <8b> 4a 04 89 e5 8d 0c cd 10 00 00 00 29 48 5c 8d 42 08 ba 40 6f 
[  174.237999] EIP: [<c05b6ed1>] sk_filter_delayed_uncharge+0x1/0x20 SS:ESP 0068:c3e05edc

Rgds

-- 
     -- Pierre Ossman

  Linux kernel, MMC maintainer        http://www.kernel.org
  PulseAudio, core developer          http://pulseaudio.org
  rdesktop, core developer          http://www.rdesktop.org
