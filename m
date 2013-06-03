From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH v8 net-next 2/7] net: add low latency
	socket poll
Date: Mon, 3 Jun 2013 15:22:29 +0300
Message-ID: <51AC8A85.5020605@mellanox.com>
References: <20130603080107.18273.34279.stgit@ladj378.jer.intel.com>
	<20130603080128.18273.2408.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130603080128.18273.2408.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 03/06/2013 11:01, Eliezer Tamir wrote:
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index 741db5fc..ae98c95 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -19,6 +19,7 @@
>  #include <net/ip.h>
>  #include <net/sock.h>
>  #include <net/net_ratelimit.h>
> +#include <net/ll_poll.h>
>  
>  static int one = 1;
>  
> @@ -284,6 +285,15 @@ static struct ctl_table net_core_table[] = {
>  		.proc_handler	= flow_limit_table_len_sysctl
>  	},
>  #endif /* CONFIG_NET_FLOW_LIMIT */
> +#ifdef CONFIG_NET_LL_RX_POLL
> +	{
> +		.procname	= "low_latency_poll",
> +		.data		= &sysctl_net_ll_poll,
> +		.maxlen		= sizeof(unsigned long),
One more thing I just noticed: should be 'sizeof(int)'.
Because proc_dointvec is expecting an int, sizeof(unsigned long) will
produce an array of two ints.


> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec
> +	},
> +#endif
>  #endif /* CONFIG_NET */
>  	{
>  		.procname	= "netdev_budget",


------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite
It's a free troubleshooting tool designed for production
Get down to code-level detail for bottlenecks, with <2% overhead.
Download for free and get started troubleshooting in minutes.
http://p.sf.net/sfu/appdyn_d2d_ap2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
