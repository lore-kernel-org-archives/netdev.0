From: Adam Huffman <adam.huffman@gmail.com>
Subject: Re: Networking-related crash?
Date: Wed, 9 Dec 2009 20:36:29 +0000
Message-ID: <608c44bf0912091236u7c33d056y9517d3d906a31207@mail.gmail.com>
References: <608c44bf0912090546s446bf973ne408e99661fdc56f@mail.gmail.com>
	 <4B1FBE0A.4040107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kvm@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:28853 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757517AbZLIUgZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 15:36:25 -0500
In-Reply-To: <4B1FBE0A.4040107@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2009 at 3:11 PM, Avi Kivity <avi@redhat.com> wrote:
> On 12/09/2009 03:46 PM, Adam Huffman wrote:
>>
>> I've been seeing lots of crashes on a new Dell Precision T7500,
>> running the KVM in Fedora 12. =A0Finally managed to capture an Oops,
>> which is shown below (hand-transcribed):
>>
>> BUG: unable to handle kernel paging request at 0000000000200200
>> IP: [<ffffffff8139aab7>] destroy_conntrack+0x82/0x11f
>> PGD 332d0e067 PUD 33453c067 PMD 0
>> Oops: 0002 [#1] SMP
>> last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cp=
u_map
>> CPU 4
>> Modules linked in: tun bridge stp llc sunrpc ipt_MASQUERADE
>> iptable_nat nf_nat ipt_LOG xt_physdev ip6t_REJECT nf_conntrack_ipv6
>> ip6table_filter ip6
>> _tables ipv6 dm_multipath kvm_intel kvm uinput snd_hda_codec_analog
>> nouveau snd_hda_intel snd_hda_codec ttm drm_kms_helper snd_hwdep
>> snd_seq drm sn
>> d_seq_device snd_pcm firewire_ohci i2c_i801 snd_timer ppdev
>> firewire_core snd i2c_algo_bit iTCO_wdt crc_itu_t parport_pc i2c_cor=
e
>> soundcore parport
>> =A0iTCO_vendor_support tg3 snd_page_alloc shpchp dcdbas wmi mptsas
>> mptscsih mptbase scsi_transport_sas megaraid_sas [last_unloaded:
>> speedstep_lib]
>> Pid: 1759, comm: qemu-kvm Not tainted 2.6.31.6-162.fc12.x86_64 #1
>> Precision WorkStation T7500
>> RIP: 0010:[<ffffffff8139aab7>] =A0[<ffffffff8139aab7>]
>> destroy_conntrack+0x82/0x11f
>> RSP: 0018:ffffc90000803bf0 =A0EFLAGS: 00010202
>> RAX: 0000000080000001 RBX: ffffffff816fb1a0 RCX: 000000000000752f
>> RDX: 0000000000200200 RSI: 0000000000000011 RDI: ffffffff816fb1a0
>> RBP: ffffc90000803c00 R08: ffff880336699438 R09: 0000000000aaa5e0
>> R10: 00000002f54189d5 R11: 0000000000000001 R12: ffffffff819a92e0
>> R13: ffffffffa029adcc R14: 0000000000000000 R15: ffff880632866c38
>> FS: =A000007fdd34b17710(0000) GS:ffffc90000800000(0000)
>> knlGS:0000000000000000
>> CS: =A00010 DS: 002B ES: 002B CR0: 0000000080050033
>> CR2: 0000000000200200 CR3: 00000003349c0000 CR4: 00000000000026e0
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Process qemu-kvm (pid: 1759, threadinfo ffff88062e9e8000, task
>> ffff880634945e00)
>> Stack:
>> =A0ffff880632866c00 ffff880634640c30 ffffc90000803c10 ffffffff813989=
c2
>> <0> =A0ffffc90000803c30 ffffffff81374092 ffffc90000803c30 ffff880632=
866c00
>> <0> =A0ffffc90000803c50 ffffffff81373dd3 0000000200000000 ffff880632=
866c00
>> Call Trace:
>> =A0<IRQ>
>> =A0[<ffffffff813989c2>] nf_conntrack_destroy+0x1b/0x1d
>> =A0[<ffffffff81374092>] skb_release_head_state+0x95/0xd7
>> =A0[<ffffffff81373dd3>] __kfree_skb+0x16/0x81
>> =A0[<ffffffff81373ed7>] kfree_skb+0x6a/0x72
>> =A0[<ffffffffa029adcc>] ip6_mc_input+0x220/0x230 [ipv6]
>> =A0[<ffffffffa029a3d1>] ip6_rcv_finish+0x27/0x2b [ipv6]
>> =A0[<ffffffffa029a763>] ipv6_rcv+0x38e/0x3e5 [ipv6]
>> =A0[<ffffffff8137bd91>] netif_receive_skb+0x402/0x427
>> =A0[<ffffffff8137bf1b>] napi_skb_finish+0x29/0x3d
>> =A0[<ffffffff8137c37a>] napi_gro_receive+0x2f/0x34
>> =A0[<ffffffffa0084fad>] tg3_poll+0x6c6/0x8c3 [tg3]
>> =A0[<ffffffff8137c4b0>] net_rx_action+0xaf/0x1c9
>> =A0[<ffffffff81379cfe>] ? list-add_tail+0x15/0x17
>> =A0[<ffffffff81057614>] __do_softirq+0xdd/0x1ad
>> =A0[<ffffffff81026936>] ? apic_write+0x16/0x18
>> =A0[<ffffffff81012eac>] call_softirq+0x1c/0x30
>> =A0[<ffffffff810143fb>] do_softirq+0x47/0x8d
>> =A0[<ffffffff81057326>] irq_exit+0x44/0x86
>> =A0[<ffffffff8141ecd5>] do_IRQ+0xa5/0xbc
>> =A0[<ffffffff810126d3>] ret_from_intr+0x0/0x11
>> =A0<EOI>
>> =A0[<ffffffffa02437bb>] ? kvm_arch_vcpu_ioctl_run+0x84b/0xb34 [kvm]
>> =A0[<ffffffffa02437aa>] ? kvm_arch_vcpu_ioctl_run+0x83a/0xb34 [kvm]
>> =A0[<ffffffffa02395e3>] ? kvm_vcpu_ioctl+0xfd/0x556 [kvm]
>> =A0[<ffffffff81108adc>] ? vfs_ioctl+0x22/0x87
>> =A0[<ffffffff81109038>] ? do_vfs_ioctl+0x47b/0x4c1
>> =A0[<ffffffff811090d4>] ? sys_ioctl+0x56/0x79
>> =A0[<ffffffff81012093>] ? stub_clone+0x13/0x20
>> =A0[<ffffffff81011cf2>] ? system_call_fastpath+0x16/0x1b
>> Code: c7 00 a6 9a 81 e8 23 04 08 00 48 89 df e8 68 29 00 00 f6 43 78
>> 08 75 24 48 8b 53 10 48 85 d2 75 04 0f 0b eb fe 48 8b 43 08 a8 01<48=
>
>> 89 02 7
>> 5 04 48 89 50 08 48 c7 43 10 00 02 20 00 65 8b 14 25
>> RIP =A0[<ffffffff8139aab7>] destroy_conntrack+0x82/0x11f
>> =A0RSP<ffffc90000803bf0>
>> CR2: 0000000000200200
>>
>
> Looks unrelated to kvm - softirq happened to trigger during a kvm ioc=
tl.
> =A0Fault looks like list poison. =A0Copying netdev.
>

Disabling VT-d support in the BIOS seems to have stopped the crashes.
At least it's been running without crashing for several hours now,
while it would only last minutes before.
