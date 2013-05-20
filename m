From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: GRE+XFRM+GSO crashes
Date: Mon, 20 May 2013 10:58:03 -0700
Message-ID: <CALnjE+qgOQUDm_gAuygpDE5VH23YS0i3QyQuCVPhgu15=jwXWw@mail.gmail.com>
References: <20130520094127.546a2f3e@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:44543 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755705Ab3ETR6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 13:58:05 -0400
Received: by mail-qe0-f48.google.com with SMTP id 9so4125032qea.35
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 10:58:04 -0700 (PDT)
In-Reply-To: <20130520094127.546a2f3e@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 19, 2013 at 11:41 PM, Timo Teras <timo.teras@iki.fi> wrote:
> Since upgrade from 3.8 to 3.9 I've started getting the below mentioned
> BUG crashes. One of the few relevant changes seems to be GSO support in
> GRE driver.
>
> Turning off SG (and GSO) seems to make these crashes disappear.
>
> The basic setup is:
> - gre1 is an NBMA tunnel (no explicit destination, nor bound
>   target interface; opennhrp daemon creates neigh mappings)
> - IPsec policy to encrypt all GRE traffic in transport mode
> - VIA Padlock hardware for AES acceleration
> - GRE traffic goes to r8169 NIC; rx on, gro on, tx off, sg off, gso off
>
> Incidentally, when I tried exact same setup ran as virtualized, I was
> unable to reproduce this crash. I suspect it depends on the target NIC
> acceleration capabilities.
>
I do not have access to this hardware, can you tell me what are target
device capabilities?

Thanks,
Pravin.
> This is from vanilla 3.9.2 kernel:
>  BUG: unable to handle kernel NULL pointer dereference at 00000010
>  IP: [<c123e5b8>] xfrm_output_resume+0x63/0x2a4
>  *pde = 00000000
>  Oops: 0000 [#1] SMP
>  Modules linked in: sha1_generic authenc esp4 xfrm4_mode_transport
>  deflate zlib_deflate ctr twofish_i586 twofish_generic twofish_common
>  camellia_generic serpent_sse2_i586 xts lrw gf128mul glue_helper
>  ablk_helper cryptd serpent_generic blowfish_generic blowfish_common
>  cast5_generic cast_common des_generic cbc xcbc rmd160 sha512_generic
>  hmac crypto_null af_key xfrm_algo ip_gre ipt_REJECT iptable_filter
>  ipt_MASQUERADE xt_nat iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4
>  nf_nat_ipv4 nf_nat ip_tables ip6t_REJECT xt_LOG xt_limit xt_recent
>  xt_policy xt_tcpudp nf_conntrack_ipv6 nf_defrag_ipv6 xt_state
>  nf_conntrack xt_multiport ip6table_filter ip6_tables x_tables ipv6
>  af_packet padlock_sha padlock_aes via_cputemp hwmon hwmon_vid
>  serio_raw psmouse pcspkr shpchp pci_hotplug i2c_viapro i2c_core
>  via_rhine snd_via82xx snd_ac97_codec snd_pcm snd_timer ac97_bus
>  snd_page_alloc snd_mpu401_uart snd_rawmidi snd_seq_device snd
>  soundcore firewire_ohci firewire_core crc_itu_t via_agp agpgart r8169
>  firmware_class mii evdev fan parport_pc parport thermal button
>  acpi_cpufreq freq_table mperf processor nls_utf8 nls_cp437 vfat fat
>  sata_via ehci_pci ehci_hcd uhci_hcd ata_generic pata_via pata_acpi
>  libata usb_storage usbcore usb_common sd_mod scsi_mod squashfs loop
>  Pid: 1794, comm: opennhrp Not tainted 3.9.2 #2-Alpine    /CN700-8237
>  EIP: 0060:[<c123e5b8>] EFLAGS: 00010246 CPU: 0
>  EIP is at xfrm_output_resume+0x63/0x2a4
>  EAX: 00000000 EBX: f0572500 ECX: f5ffc8b8 EDX: 00000064
>  ESI: f0496400 EDI: 00000000 EBP: f0499bf8 ESP: f0499be8
>   DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
>  CR0: 80050033 CR2: 00000010 CR3: 3104c000 CR4: 00000690
>  DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>  DR6: ffff0ff0 DR7: 00000400
>  Process opennhrp (pid: 1794, ti=f0498000 task=f670eff0 task.ti=f0498000)
>  Stack:
>   f0496420 f0572500 c1236810 f0572528 f0499c00 c123e806 f0499c14 c123e89b
>   f0572500 c1236810 f0572528 f0499c1c c1236837 f0499c2c c1236865 f0572500
>   0000003c f0499c38 c12016e7 f0572500 f0499cb0 f84175fb f0572a00 f04bb400
>  Call Trace:
>   [<c1236810>] ? xfrm4_extract_output+0x8c/0x8c
>   [<c123e806>] xfrm_output2+0xd/0xf
>   [<c123e89b>] xfrm_output+0x93/0xa0
>   [<c1236810>] ? xfrm4_extract_output+0x8c/0x8c
>   [<c1236837>] xfrm4_output_finish+0x27/0x29
>   [<c1236865>] xfrm4_output+0x2c/0x63
>   [<c12016e7>] ip_local_out+0x1b/0x1e
>   [<f84175fb>] ipgre_tunnel_xmit+0x80a/0x892 [ip_gre]
>   [<c11ddff1>] dev_hard_start_xmit+0x27d/0x37c
>   [<c11de379>] dev_queue_xmit+0x289/0x31a
>   [<f8332308>] packet_sendmsg+0x933/0x9d0 [af_packet]
>   [<c1040200>] ? ttwu_do_wakeup+0xe/0xa8
>   [<f8416874>] ? ipgre_header_parse+0x15/0x15 [ip_gre]
>   [<c11cd5a9>] sock_sendmsg+0x79/0x94
>   [<c10b33d4>] ? __pollwait+0xa4/0xa4
>   [<c11cd7e3>] __sys_sendmsg+0x16e/0x1f3
>   [<c10367c5>] ? free_pid+0x99/0x9f
>   [<c106b92a>] ? call_rcu_sched+0xf/0x12
>   [<c1026e15>] ? release_task+0x36d/0x37d
>   [<c10390e8>] ? remove_wait_queue+0x31/0x36
>   [<c1027a1d>] ? do_wait+0x1a8/0x1b5
>   [<c11cef10>] sys_sendmsg+0x2b/0x46
>   [<c11cf394>] sys_socketcall+0x145/0x19f
>   [<c1257888>] syscall_call+0x7/0xb
>  Code: ff 8b 43 74 c7 43 70 00 00 00 00 85 c0 74 0f 3e ff 08 0f 94 c2 84 d2 74 05 e8 35 17 e6 ff 8b 43 48 c7 43 74 00 00 00 00 83 e0 fe <8b> 50 10 89 d8 ff 52 34 83 f8 01 89 c7 0f 85 24 02 00 00 8b 53
>  EIP: [<c123e5b8>] xfrm_output_resume+0x63/0x2a4 SS:ESP 0068:f0499be8
>  CR2: 0000000000000010
>  ---[ end trace ac96c6b6b1a4992f ]---
>  Kernel panic - not syncing: Fatal exception in interrupt
>
>
> Based on the disassembly, it seems the crash happens in
> net/xfrm/xfrm_output.c:
>
> int xfrm_output_resume(struct sk_buff *skb, int err)
> {
>         while (likely((err = xfrm_output_one(skb, err)) == 0)) {
>                 nf_reset(skb);
>
>                 err = skb_dst(skb)->ops->local_out(skb);
>                       ^^^^^^^^^^^^ is NULL
>                 if (unlikely(err != 1))
>                         goto out;
>
>                 if (!skb_dst(skb)->xfrm)
>                         return dst_output(skb);
