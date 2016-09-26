From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nfp: bpf: improve handling for disabled BPF syscall
Date: Mon, 26 Sep 2016 02:28:09 -0400 (EDT)
Message-ID: <20160926.022809.551158468707292513.davem@davemloft.net>
References: <20160923202443.4130858-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, oss-drivers@netronome.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160923202443.4130858-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 23 Sep 2016 22:23:59 +0200

> I stumbled over a new warning during randconfig testing,
> with CONFIG_BPF_SYSCALL disabled:
> 
> drivers/net/ethernet/netronome/nfp/nfp_net_offload.c: In function 'nfp_net_bpf_offload':
> drivers/net/ethernet/netronome/nfp/nfp_net_offload.c:263:3: error: '*((void *)&res+4)' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> drivers/net/ethernet/netronome/nfp/nfp_net_offload.c:263:3: error: 'res.n_instr' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> As far as I can tell, this is a false positive caused by the compiler
> getting confused about a function that is partially inlined, but it's
> easy to avoid while improving the code:
> 
> The nfp_bpf_jit() stub helper for that configuration is unusual as it
> is defined in a header file but not marked 'static inline'. By moving
> the compile-time check into the caller using the IS_ENABLED() macro,
> we can remove that stub and simplify the nfp_net_bpf_offload_prepare()
> function enough to unconfuse the compiler.
> 
> Fixes: 7533fdc0f77f ("nfp: bpf: add hardware bpf offload")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
