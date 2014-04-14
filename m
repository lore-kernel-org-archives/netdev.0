From: Zhan Jianyu <nasa4836@gmail.com>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering
 updating to
Date: Tue, 15 Apr 2014 01:01:28 +0800
Message-ID: <CAHz2CGVVx3Fi5Vy0dr7z5r2yerbg9cjux61NM0fVeMAtK_Wf9Q@mail.gmail.com>
References: <CAHz2CGWs-JH0v3dWAMBDrKqkP6ygb48YZ-qkc=KsFqz5yO7f+Q@mail.gmail.com>
 <CAHz2CGU5aPA5QJ9ED9g5kahD_jJaeLF+VOotUSBFXDkY+EH8ow@mail.gmail.com> <534BFC69.6080209@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
	joe@perches.com, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <534BFC69.6080209@katalix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 14, 2014 at 11:19 PM, James Chapman <jchapman@katalix.com> wrote:
> Please send the complete oops message.

Hi, complete oops message is :


[  100.243737] BUG: unable to handle kernel NULL pointer dereference
at 00000000000002c0
[  100.244985] IP: [<ffffffff815d4cb0>] ip_queue_xmit+0x20/0x3e0
[  100.262266] PGD 0
[  100.288395] Oops: 0000 [#1] SMP
[  100.325955] Modules linked in: l2tp-ppp l2tp-netlink l2tp_core
pppoe vmblock vsock vmmemctl vmhgfs acpiphp snd_ens1371 gameport
snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm
snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event
snd_seq snd_timer snd_seq_device ppdev psmouse serio_raw fbcon
tileblit font bitblit softcursor snd parport_pc soundcore
snd_page_alloc vmci i2c_piix4 vga16fb vgastate intel_agp agpgart
shpchp lp parport floppy pcnet32 mii mptspi mptscsih mptbase
scsi_transport_spi vmxnet
[  1100.472178] CPU: 0 PID: 1849 Comm: pppd Tainted: G        IOE
3.15.0-rc1+ #13
[  1100.540018] Hardware name: LENOVO 20216/v2QY041, BIOS
74CN34WW(v2.0k) 07/04/2013
[  1100.562844] task: ffff88003ee48000 ti: ffff880257a4e000 task.ti:
ffff880257a4e000
[  1100.584351] RIP: 0010: [<ffffffff815d4cb0>]  [<ffffffff815d4cb0>]
ip_queue_xmit+0x20/0x3e0
[  1100.584351] RSP: 0018: ffff880257a4fdd8 EFLAGS: 00010293
[  1100.609358] RAX: ffff88003fe48e00 RBX:ffff88003f5ad100 RCX:0000000000000014
[  1100.631467] RDX: ffffffff81ccab40   RSI:  ffff88003fe49110
RDI:ffff88003f5ad100
[  1100.657664] RBP: ffff880257a4fe00 R08:  ffff88807ff06476
R09:0000000000000022
[  1100.657694] R10:  ffffe90009726600 R11:  ffff88003fe49110
R12:0000000000000000
[  1100.657694] R13:  ffff88025a087480 R14:  ffff880025b561400
R15:ffff88003fe49110
[  1100.688994] FS:    00007f8857f8f840(0000)
GS:ffff88026f200000(0000) knlGS:000000000000
[  1100.697694] CS: 0010 DS: 0000 ES: 0000 CR0:0000000080050033
[  1100.697694] CR2:0000000000002c0 CR3: 0000000260190e00 CR4: 00000000001407f0
[  1100.706083] Stack:
[  1100.731783]  ffff88025cadbe00 ffff88003fe48e00 0000000000000022
ffff88025b561400
[  1100.759324]  ffff88003f5ad100  ffff880257a4fe68 ffffffffa081a6e5
ffff88003f5ad100
[  1100.811396]  ffff880257a4fe28  ffffffff8158686e   ffff880257a4fe68
 ffffffff000000008
[  1100.891922] Call Trace:
[  1100.916257]  [<ffffffffa081a6e5>] l2tp_xmit_skb+0x335/0x6c0 [l2tp_core]
[  1100.943670]  [<ffffffff8158686e>] ? skb_free_head+0x1e/0x80
[  1100.970905]  [<ffffffffa0830da1>] pppol2tp_xmit+0x141/0x210 [l2tp_ppp]
[  1100.995542]  [<ffffffffa0805230>] ppp_channel_push+0x50/0xd0 [ppp_generic]
[  1101.024087]  [<ffffffffa0805523>] ppp_write+0xa3/0xec [ppp_generic]
[  1101.133447]  [<ffffffff811c7bfa>] vfs_write+0xba/0x1e0
[  1101.228987]  [<ffffffff811c8746>] Sys_wirte+0x46/0xb0
[  1101.428494]  [<ffffffff8110aca6>] ? __audit_syscall_exit+0x1f6/0x2a0
[  1101.898345]  [<ffffffff816a90e9>] system_call_fastpath+0x16/0x1b
[  1102.024087] Code: e9 31 fe ff ff 66 0f 1f 44 00 00 0f 1f 44 00 00
55 48 89 e5 41 57 49 89 f7 41 55 41 54 53 48 89 fb 4c 8b 67 18 4c 8b
67 18 4c 8b 6f 58 <4d> 8b b4 24 c0 02 00 00 49 83 e5 fe 0f 84 3e 02 00
00 4d 85 f6
[  1102.879592] RIP: [<ffffffff815d4cb0>] ip_queue_xmit+0x20/0x3e0
[  1103.179592]   RsP<FFFF880257A4FDD8>
[  1103.834682] CR2: 00000000000002C0
[  1104.043682] kernel panic - not syncing: Fatal exception in interrupt
[  1104.789539] Offset: 0x0 from 0xffffffff81000000 (relocation range:
0xffffffff80000000-0xffffffff9fffffff)

>Is this a regression? If so, do you know what the last kernel version
>was that worked?

I think this is a regression. 3.14 is the good working version. Today,
after I updated to 3.15-rc1,  evertime I tried connect my VPN, it
always panics.
