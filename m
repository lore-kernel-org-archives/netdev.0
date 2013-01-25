From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch] ipvs: freeing uninitialized pointer on error
Date: Fri, 25 Jan 2013 22:56:11 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1301252244200.1872@ja.ssi.bg>
References: <20130125154456.GB5908@elgon.mountain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54160 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418Ab3AYUxr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 15:53:47 -0500
In-Reply-To: <20130125154456.GB5908@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 25 Jan 2013, Dan Carpenter wrote:

> If state != IP_VS_STATE_BACKUP then tinfo->buf is uninitialized.  If
> kthread_run() fails then it means we free random memory resulting in an
> oops.

	Good catch. Simon, please apply!

	Problem is in 3.5+ caused by commit f73181c828
(ipvs: add support for sync threads)

> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Julian Anastasov <ja@ssi.bg>

> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index effa10c..44fd10c 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1795,6 +1795,8 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
>  					     GFP_KERNEL);
>  			if (!tinfo->buf)
>  				goto outtinfo;
> +		} else {
> +			tinfo->buf = NULL;
>  		}
>  		tinfo->id = id;

Regards

--
Julian Anastasov <ja@ssi.bg>
