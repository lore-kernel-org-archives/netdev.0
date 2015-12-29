From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] bpf: hash: use per-bucket spinlock
Date: Tue, 29 Dec 2015 15:14:05 -0500 (EST)
Message-ID: <20151229.151405.518049202533460569.davem@davemloft.net>
References: <1451400027-28892-1-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ast@kernel.org,
	netdev@vger.kernel.org, daniel@iogearbox.net
To: tom.leiming@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451400027-28892-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <tom.leiming@gmail.com>
Date: Tue, 29 Dec 2015 22:40:24 +0800

> Hi,
> 
> This patchset tries to optimize ebpf hash map, and follows
> the idea:
> 
>         Both htab_map_update_elem() and htab_map_delete_elem()
>         can be called from eBPF program, and they may be in kernel
>         hot path, it isn't efficient to use a per-hashtable lock
>         in this two helpers, so this patch converts the lock into
>         per-bucket spinlock.
> 
> With this patchset, looks the performance penalty from eBPF
> decreased a lot, see the following test:
> 
>         1) run 'tools/biolatency' of bcc before running block test;
> 
>         2) run fio to test block throught over /dev/nullb0,
>         (randread, 16jobs, libaio, 4k bs) and the test box
>         is one 24cores(dual sockets) VM server:
>         - without patchset:  607K IOPS
>         - with this patchset: 1184K IOPS
>         - without running eBPF prog: 1492K IOPS

Series applied, thanks.
