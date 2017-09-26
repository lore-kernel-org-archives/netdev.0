From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: WARNING: kernel stack frame pointer at ffff880156a5fea0 in
 bash:2103 has bad value 00007ffec7d87e50
Date: Mon, 25 Sep 2017 21:09:02 -0700
Message-ID: <20170926040900.mlhx3bw7j7zn42qa@ast-mbp>
References: <2656822.vqnppgTvlm@blindfold>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Richard Weinberger <richard@sigma-star.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2656822.vqnppgTvlm@blindfold>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2017 at 11:23:31PM +0200, Richard Weinberger wrote:
> Hi!
> 
> While playing with bcc's opensnoop tool on Linux 4.14-rc2 I managed to trigger 
> this splat:
> 
> [  297.629773] WARNING: kernel stack frame pointer at ffff880156a5fea0 in 
> bash:2103 has bad value 00007ffec7d87e50
> [  297.629777] unwind stack type:0 next_sp:          (null) mask:0x6 
> graph_idx:0
> [  297.629783] ffff88015b207ae0: ffff88015b207b68 (0xffff88015b207b68)
> [  297.629790] ffff88015b207ae8: ffffffffb163c00e (__save_stack_trace+0x6e/
> 0xd0)
> [  297.629792] ffff88015b207af0: 0000000000000000 ...
> [  297.629795] ffff88015b207af8: ffff880156a58000 (0xffff880156a58000)
> [  297.629799] ffff88015b207b00: ffff880156a60000 (0xffff880156a60000)
> [  297.629800] ffff88015b207b08: 0000000000000000 ...
> [  297.629803] ffff88015b207b10: 0000000000000006 (0x6)
> [  297.629806] ffff88015b207b18: ffff880151b02700 (0xffff880151b02700)
> [  297.629809] ffff88015b207b20: 0000010100000000 (0x10100000000)
> [  297.629812] ffff88015b207b28: ffff880156a5fea0 (0xffff880156a5fea0)
> [  297.629815] ffff88015b207b30: ffff88015b207ae0 (0xffff88015b207ae0)
> [  297.629818] ffff88015b207b38: ffffffffc0050282 (0xffffffffc0050282)
> [  297.629819] ffff88015b207b40: 0000000000000000 ...
> [  297.629822] ffff88015b207b48: 0000000001000000 (0x1000000)
> [  297.629825] ffff88015b207b50: ffff880157b98280 (0xffff880157b98280)
> [  297.629828] ffff88015b207b58: ffff880157b98380 (0xffff880157b98380)
> [  297.629831] ffff88015b207b60: ffff88015ad2b500 (0xffff88015ad2b500)
> [  297.629834] ffff88015b207b68: ffff88015b207b78 (0xffff88015b207b78)
> [  297.629838] ffff88015b207b70: ffffffffb163c086 (save_stack_trace+0x16/0x20)
> [  297.629841] ffff88015b207b78: ffff88015b207da8 (0xffff88015b207da8)
> [  297.629847] ffff88015b207b80: ffffffffb18a8ed6 (save_stack+0x46/0xd0)
> [  297.629850] ffff88015b207b88: 000000400000000c (0x400000000c)
> [  297.629852] ffff88015b207b90: ffff88015b207ba0 (0xffff88015b207ba0)
> [  297.629855] ffff88015b207b98: ffff880100000000 (0xffff880100000000)
> [  297.629859] ffff88015b207ba0: ffffffffb163c086 (save_stack_trace+0x16/0x20)
> [  297.629864] ffff88015b207ba8: ffffffffb18a8ed6 (save_stack+0x46/0xd0)
> [  297.629868] ffff88015b207bb0: ffffffffb18a9752 (kasan_slab_free+0x72/0xc0)

Thanks for the report!
I'm not sure I understand what's going on here.
It seems you have kasan enabled and it's trying to do save_stack()
and something crashing?
I don't see any bpf related helpers in the stack trace.
Which architecture is this? and .config ?
Is bpf jit enabled? If so, make sure that net.core.bpf_jit_kallsyms=1
