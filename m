From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 06/24] net, diet: Use small UDP hash tables on small
 kernels
Date: Tue, 06 May 2014 07:26:42 -0700
Message-ID: <1399386402.15399.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	 <1399328773-6531-7-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, Andi Kleen <ak@linux.intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-7-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-05-05 at 15:25 -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> UDP has two hash tables, for UDP and UDP lite. Default
> them to 16 entries each on small kernels. This can be
> still overriden on the command line.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  net/ipv4/udp.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 4468e1a..90f967b 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2415,7 +2415,12 @@ void udp4_proc_exit(void)
>  }
>  #endif /* CONFIG_PROC_FS */
>  
> +#ifdef CONFIG_BASE_SMALL
> +static __initdata unsigned long uhash_entries = 16;
> +#else
>  static __initdata unsigned long uhash_entries;
> +#endif
> +
>  static int __init set_uhash_entries(char *str)
>  {
>  	ssize_t ret;

Its changed to UDP_HTABLE_SIZE_MIN later in alloc_large_system_hash()

The reason there is a minimum UDP hash size is PORTS_PER_CHAIN,
or DECLARE_BITMAP(bitmap, PORTS_PER_CHAIN) on stack.

This patch has no effect on a small machine, because we already
dynamically size this hash table.

(The factor is one slot per 2MB of low memory)
