From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [net] BUG: unable to handle kernel NULL pointer dereference at
 000000000000022f
Date: Tue, 13 May 2014 07:14:26 +0200
Message-ID: <5371AA32.6070407@hartkopp.net>
References: <537188D4.6050201@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
To: Jet Chen <jet.chen@intel.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <537188D4.6050201@intel.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jet,

this is likely not CAN related, as

# CONFIG_CAN is not set

and all the CAN changes introduced by Marc's merge are not even compiled in
your setup.

So I assume the issue somewhere in the netlink or ipv6 stuff (see commit at
the end.

Best regards,
Oliver


On 13.05.2014 04:52, Jet Chen wrote:

> [    1.301982]  [<ffffffff8163ee35>] netlink_bind+0x1e5/0x220
> [    1.301982]  [<ffffffff815f57e8>] SYSC_bind+0xb8/0xf0
> [    1.301982]  [<ffffffff815fbcd8>] ? sock_setsockopt+0x1a8/0x9c0
> [    1.301982]  [<ffffffff815f6926>] ? SyS_setsockopt+0xb6/0xd0
> [    1.301982]  [<ffffffff815f671e>] SyS_bind+0xe/0x10
> [    1.301982]  [<ffffffff81752be9>] system_call_fastpath+0x16/0x1b
> [    1.301982] Code: 50 48 85 c0 74 06 ff d0 5d c3 66 90 41 ff 51 40 5d c3 66
> 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 41 54 41 89 d4 53 <48>
> 8b 87 30 02 00 00 48 89 f3 48 8b 78 18 e8 ae 94 a7 ff 31 d2 [    1.301982]
> RIP  [<ffffffff815f7b3f>] sk_ns_capable+0xf/0x40
> [    1.301982]  RSP <ffff88000becfe58>
> [    1.301982] CR2: 000000000000022f
> [    1.337456] ---[ end trace e34617f32717aa50 ]---
> [    1.338240] Kernel panic - not syncing: Fatal exception
> 
> Attached dmesg for the parent commit, too, to help confirm whether it is a
> noise error.
> 


> # first bad commit: [0a240764becbec91589bd579b591c2fcf2df2bcf] Merge tag
> 'linux-can-fixes-for-3.15-20140424' into HEAD
> git bisect good 163cd4e817a4444e348ca577cb74c71d245f0c72  # 01:08     60+     
> 2  ipv6: remove parameter rt from fib6_prune_clones()
> git bisect good 367525c8c20a34560afe1d0c7cca52a44ccd62e9  # 01:11     60+     
