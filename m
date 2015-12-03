From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix allocation warnings in bpf maps and
 integer overflow
Date: Wed, 02 Dec 2015 23:36:28 -0500 (EST)
Message-ID: <20151202.233628.1791728126876403392.davem@davemloft.net>
References: <CACT4Y+b1k7Ofvn6xa=qWv9xP6BbteWOnZsJMXLZ=GOby-ajF=w@mail.gmail.com>
	<20151130005934.GA95228@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, edumazet@google.com,
	sasha.levin@oracle.com, daniel@iogearbox.net
To: alexei.starovoitov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151130005934.GA95228@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Sun, 29 Nov 2015 16:59:35 -0800

> From: Alexei Starovoitov <ast@kernel.org>
> 
> For large map->value_size the user space can trigger memory allocation warnings like:
 ...
> To avoid never succeeding kmalloc with order >= MAX_ORDER check that
> elem->value_size and computed elem_size are within limits for both hash and
> array type maps.
> Also add __GFP_NOWARN to kmalloc(value_size | elem_size) to avoid OOM warnings.
> Note kmalloc(key_size) is highly unlikely to trigger OOM, since key_size <= 512,
> so keep those kmalloc-s as-is.
> 
> Large value_size can cause integer overflows in elem_size and map.pages
> formulas, so check for that as well.
> 
> Fixes: aaac3ba95e4c ("bpf: charge user for creation of BPF maps and programs")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied and queued up for -stable, thanks.
