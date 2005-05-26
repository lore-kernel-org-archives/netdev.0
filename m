From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6] fix deadlock with ip_queue and tcp local input path
Date: Fri, 27 May 2005 07:38:57 +1000
Message-ID: <E1DbQ49-00027X-00@gondolin.me.apana.org.au>
References: <20050526142420.GD13114@sunbeam.de.gnumonks.org>
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org (Harald Welte)
In-Reply-To: <20050526142420.GD13114@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Harald Welte <laforge@netfilter.org> wrote:
> 
> The patch below adds an additional queue for ip_queue verdicts.  They
> come up from userspace, are appended to a queue which is then processed
> by a tasklet.  The tasklet itself runs in softirq context, so when timer
> hardirq leaves, no tcp_delack_timer() will be executed until
> nf_reinject() has finished.

This seems to be overly complicated if all you want is to do this in
softirq context.  What's wrong with simply alling local_bh_disable?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
