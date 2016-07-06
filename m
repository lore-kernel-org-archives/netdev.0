From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Network hang after c3f1010b30f7fc611139cfb702a8685741aa6827 with
 CIPSO & Smack
Date: Wed, 6 Jul 2016 11:56:37 -0700
Message-ID: <5f0df0df-8542-2938-9d19-0bf49f4b12b7@schaufler-ca.com>
References: <e5ba1ba9-acf6-c36c-03e4-4cdc81e81648@schaufler-ca.com>
 <7d833f59-c68f-f779-4de4-15bc0b26ac7c@cumulusnetworks.com>
 <66709b13-15a7-8d03-9e84-e4be9aab60b5@schaufler-ca.com>
 <9998a0da-b273-43d4-84ad-a0539e6a69ac@cumulusnetworks.com>
 <5de95a23-fd64-d911-d4b0-88de51ab12a4@schaufler-ca.com>
 <9cb32128-176b-85cf-8ea8-465704f667e7@cumulusnetworks.com>
 <6d1249a6-6176-414e-0df8-d7df8dac1cbd@schaufler-ca.com>
 <79be6a80-f8e4-c386-f877-2c0d52609892@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux-Netdev <netdev@vger.kernel.org>,
	Casey Schaufler <casey@schaufler-ca.com>
To: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm15.bullet.mail.bf1.yahoo.com ([98.139.212.174]:37694 "EHLO
	nm15.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754068AbcGFS4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 14:56:40 -0400
In-Reply-To: <79be6a80-f8e4-c386-f877-2c0d52609892@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/2016 11:43 AM, David Ahern wrote:
> On 7/6/16 11:01 AM, Casey Schaufler wrote:
>> I find the test occasionally passes without hanging, but will
>> hang the system if repeated. I am running on Ubuntu and Fedora,
>> both with systemd, which may be a contributing factor. I run
>> under qemu, and am based on Linus' tree.
>>
>
> With this:
>
> for n in $(seq 1 10); do
>     bash -x ./testnetworking.sh
>     sleep 10
> done
>
> I do get the VM to loop where I can not kill the test. dmesg has this splat:
>
> [ 3576.504715] general protection fault: 0000 [#21] SMP
> [ 3576.505322] Modules linked in: 8021q garp mrp stp llc
> [ 3576.506007] CPU: 3 PID: 2938 Comm: killall Tainted: G      D 4.7.0-rc5+ #20
> [ 3576.506881] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [ 3576.508048] task: ffff8800b4e72340 ti: ffff880138a48000 task.ti: ffff880138a48000
> [ 3576.508894] RIP: 0010:[<ffffffff81184dc2>]  [<ffffffff81184dc2>] next_tgid+0x53/0x99
> [ 3576.509803] RSP: 0018:ffff880138a4bde8  EFLAGS: 00010206
> [ 3576.510410] RAX: 4100646e4100608e RBX: 00000000000007f2 RCX: ffff8800b98c9bb0
> [ 3576.511218] RDX: 4100646e4100608e RSI: 00000000000003e0 RDI: ffff8800b98c9b80
> [ 3576.512024] RBP: ffff880138a4be10 R08: 0000000000000032 R09: 0000000000000000
> [ 3576.512833] R10: 0000000000000000 R11: 0000000000000200 R12: 00000000000007e5
> [ 3576.513647] R13: ffff8800b98c9b80 R14: ffffffff81a27900 R15: 00000000000007e4
> [ 3576.514453] FS:  00007fc084469700(0000) GS:ffff88013fd80000(0000) knlGS:0000000000000000
> [ 3576.515361] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 3576.516009] CR2: 0000000001947000 CR3: 00000000b5449000 CR4: 00000000000406e0
> [ 3576.516818] Stack:
> [ 3576.517057]  00000000000007e5 0000000000000000 ffff880138a4bee0 ffff8800b982a140
> [ 3576.517963]  ffffffff81a27900 ffff880138a4be68 ffffffff81187090 ffff8800b1d9d300
> [ 3576.518857]  0030323032000001 ffff880138a4bee0 ffff880138a4bee0 0000000000000000
> [ 3576.519754] Call Trace:
> [ 3576.520044]  [<ffffffff81187090>] proc_pid_readdir+0xd4/0x18b
> [ 3576.520697]  [<ffffffff81183d6b>] proc_root_readdir+0x35/0x3a
> [ 3576.521352]  [<ffffffff8114951a>] iterate_dir+0xac/0x148
> [ 3576.521966]  [<ffffffff811513ad>] ? __fget_light+0x27/0x48
> [ 3576.522587]  [<ffffffff81149892>] SyS_getdents+0x8a/0xdc
> [ 3576.523189]  [<ffffffff8114967d>] ? fillonedir+0xc7/0xc7
> [ 3576.523794]  [<ffffffff814a2172>] entry_SYSCALL_64_fastpath+0x1a/0xa4
> [ 3576.524524]  [<ffffffff814a2172>] ? entry_SYSCALL_64_fastpath+0x1a/0xa4
> [ 3576.525276] Code: d6 aa ed ff 48 85 c0 49 89 c5 74 40 4c 89 f6 48 89 c7 e8 8b a2 ed ff 31 f6 4c 89 ef 89 c3 e8 15 a2 ed ff 48 85 c0 48 89 c2 74 17 <48> 8b 80 78 05 00 00 48 8b 80 c8 00 00 00 48 39 82 f0 03 00 00
> [ 3576.528359] RIP  [<ffffffff81184dc2>] next_tgid+0x53/0x99
> [ 3576.528991]  RSP <ffff880138a4bde8>
> [ 3576.529452] ---[ end trace a6f0cb9bfb70d9e6 ]---
>
> And then I can no longer run commands:
>
> root@kenny-jessie3:~# top -d1
> Segmentation fault
>
My thought is that there's a locking issue on a resource
somewhere in the TCP stack, and that a freed but still in
use buffer is getting into the filesystem code somehow.
