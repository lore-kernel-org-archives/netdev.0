From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] proportional share accept()
Date: Wed, 25 Feb 2004 21:35:38 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0402252132560.4472-100000@thoron.boston.redhat.com>
References: <Pine.LNX.4.44.0402250818060.2878-100000@loopback.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vivek Kashyap <kashyapv@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0402250818060.2878-100000@loopback.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2004, Vivek Kashyap wrote:

>  static inline int tcp_synq_is_full(struct sock *sk)
> @@ -1796,6 +1785,12 @@
>  	req->acked = 0;
>  	req->ecn_ok = 0;
>  	req->rmt_port = skb->h.th->source;
> +	req->acceptq_start_ticket = 0;
> +	req->acceptq_time_stamp = 0;
> +	if (tp->acceptq_max_class)
> +		req->acceptq_class = (skb->nfmark <= 0) ? 0 :
> +			((skb->nfmark > NUM_ACCEPT_QUEUES) ?
> +			 0: skb->nfmark);
>  }

Have you tried compiling this without CONFIG_NETFILTER?


- James
-- 
James Morris
<jmorris@redhat.com>
