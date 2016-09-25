From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] nfp: bpf: improve handling for disabled BPF syscall
Date: Sun, 25 Sep 2016 16:52:00 +0100
Message-ID: <20160925165200.41266650@jkicinski-Precision-T1700>
References: <20160923202443.4130858-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, oss-drivers@netronome.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160923202443.4130858-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Sep 2016 22:23:59 +0200, Arnd Bergmann wrote:
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

Thanks Arnd!  static inline definitely missing there but if we can
depend on dead code elimination to remove the symbol that's even cooler!

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
