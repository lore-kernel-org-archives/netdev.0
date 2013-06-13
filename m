From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 3/4] net: change
 sysctl_net_ll_poll into an unsigned int
Date: Thu, 13 Jun 2013 08:31:11 -0700
Message-ID: <1371137471.3252.110.camel@edumazet-glaptop>
References: <20130613144613.4875.46858.stgit@ladj378.jer.intel.com>
	<20130613144645.4875.47741.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	linux-kernel@vger.kernel.org, sockperf-dev@googlegroups.com,
	Avner Ben Hanoch <avnerb@mellanox.com>, Andi Kleen <andi@firstfloor.org>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130613144645.4875.47741.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-13 at 17:46 +0300, Eliezer Tamir wrote:
> There is no reason for sysctl_net_ll_poll to be an unsigned long.
> Change it into an unsigned int.
> Fix the proc handler.
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---
> 
>  include/net/ll_poll.h      |    2 +-
>  net/core/sysctl_net_core.c |    4 ++--
>  net/socket.c               |    2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
> index c75a611..9f7007f 100644
> --- a/include/net/ll_poll.h
> +++ b/include/net/ll_poll.h
> @@ -30,7 +30,7 @@
>  #ifdef CONFIG_NET_LL_RX_POLL
>  
>  struct napi_struct;
> -extern unsigned long sysctl_net_ll_poll __read_mostly;
> +extern unsigned int sysctl_net_ll_poll __read_mostly;
>  

Oh well, you re-introduce the overflow

hint : you defined 

#define USECS_TO_NS(us) (us << 10)



------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
