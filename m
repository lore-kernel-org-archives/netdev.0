From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4 net-next 2/4] tcp: add TCP support for
 low latency receive poll.
Date: Tue, 21 May 2013 18:30:18 +0100
Message-ID: <1369157418.2615.30.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130521142641.18498.52856.stgit@ladj378.jer.intel.com>
	<20130521142659.18498.1984.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Eilon Greenstien <eilong@broadcom.com>, Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130521142659.18498.1984.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-21 at 17:27 +0300, Eliezer Tamir wrote:
> adds busy-poll support for TCP.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---
> 
>  net/ipv4/tcp.c       |    9 +++++++++
>  net/ipv4/tcp_input.c |    4 ++++
>  2 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index dcb116d..b9cc512 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
[...]
> @@ -1551,6 +1553,12 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  	struct sk_buff *skb;
>  	u32 urg_hole = 0;
>  
> +#ifdef CONFIG_INET_LL_RX_POLL
> +	if (sk_valid_ll(sk) && skb_queue_empty(&sk->sk_receive_queue)
> +	    && (sk->sk_state == TCP_ESTABLISHED))
> +		sk_poll_ll(sk, nonblock);
> +#endif
[...]

I don't think the #ifdef is needed; this should compile down to nothing
if the config option is disabled.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
