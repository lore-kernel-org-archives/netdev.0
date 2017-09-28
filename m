From: Tejun Heo <tj@kernel.org>
Subject: Re: EBPF-triggered WARNING at mm/percpu.c:1361 in v4-14-rc2
Date: Thu, 28 Sep 2017 07:52:11 -0700
Message-ID: <20170928145211.GD15129@devbig577.frc2.facebook.com>
References: <20170928112727.GA11310@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, syzkaller@googlegroups.com,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Christoph Lameter <cl@linux.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20170928112727.GA11310@leverpostej>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Sep 28, 2017 at 12:27:28PM +0100, Mark Rutland wrote:
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 59d44d6..f731c45 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -1355,8 +1355,13 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
>         bits = size >> PCPU_MIN_ALLOC_SHIFT;
>         bit_align = align >> PCPU_MIN_ALLOC_SHIFT;
>  
> -       if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE ||
> -                    !is_power_of_2(align))) {
> +       if (unlikely(size > PCPU_MIN_UNIT_SIZE)) {
> +               pr_warn("cannot allocate pcpu chunk of size %zu (max %zu)\n",
> +                       size, PCPU_MIN_UNIT_SIZE);

WARN_ONCE() probably is the better choice here.  We wanna know who
tries to allocate larger than the supported size and increase the size
limit if warranted.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
