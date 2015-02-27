From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH net-next 09/10] arm64: unexport set_memory_ro and
 set_memory_rw
Date: Fri, 27 Feb 2015 19:54:43 +0000
Message-ID: <20150227195443.GD24818@arm.com>
References: <cover.1425040939.git.daniel@iogearbox.net>
 <cb778076d2d089dd52605b8eaad3ee6097e61eae.1425040940.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"ast@plumgrid.com" <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Laura Abbott <lauraa@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cb778076d2d089dd52605b8eaad3ee6097e61eae.1425040940.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 27, 2015 at 02:55:41PM +0000, Daniel Borkmann wrote:
> This effectively unexports set_memory_ro and set_memory_rw functions from
> commit 11d91a770f1f ("arm64: Add CONFIG_DEBUG_SET_MODULE_RONX support").
> 
> No module user of those is in mainline kernel and we explicitly do not want
> modules to use these functions, as they i.e. protect eBPF (interpreted and
> JIT'ed) images from malicious modifications or bugs.
> 
> Outside of eBPF scope, I believe also other set_memory_* functions should
> be unexported on arm64 for modules.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Laura Abbott <lauraa@codeaurora.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: linux-kernel@vger.kernel.org
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  arch/arm64/mm/pageattr.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/arch/arm64/mm/pageattr.c b/arch/arm64/mm/pageattr.c
> index bb0ea94..8659357 100644
> --- a/arch/arm64/mm/pageattr.c
> +++ b/arch/arm64/mm/pageattr.c
> @@ -70,7 +70,6 @@ int set_memory_ro(unsigned long addr, int numpages)
>  					__pgprot(PTE_RDONLY),
>  					__pgprot(PTE_WRITE));
>  }
> -EXPORT_SYMBOL_GPL(set_memory_ro);
>  
>  int set_memory_rw(unsigned long addr, int numpages)
>  {
> @@ -78,7 +77,6 @@ int set_memory_rw(unsigned long addr, int numpages)
>  					__pgprot(PTE_WRITE),
>  					__pgprot(PTE_RDONLY));
>  }
> -EXPORT_SYMBOL_GPL(set_memory_rw);
>  
>  int set_memory_nx(unsigned long addr, int numpages)
>  {

Looks good to me. Can this be applied independently, or does it need to
remain part of your series?

Will
