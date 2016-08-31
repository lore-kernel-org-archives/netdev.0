From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [RT PATCH 1/2] net: add back the missing serialization in
 ip_send_unicast_reply()
Date: Wed, 31 Aug 2016 18:36:14 +0200
Message-ID: <20160831163613.dg5hgb6l2jd5b5ms@linutronix.de>
References: <20160831160049.14303-1-bigeasy@linutronix.de>
 <20160831121553.6aea5cda@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
        tglx@linutronix.de, netdev@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160831121553.6aea5cda@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-08-31 12:15:53 [-0400], Steven Rostedt wrote:
> > @@ -689,10 +691,13 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
> >  		     offsetof(struct inet_timewait_sock, tw_bound_dev_if));
> >  
> >  	arg.tos = ip_hdr(skb)->tos;
> > +
> > +	local_lock(tcp_sk_lock);
> 
> Interesting that I noticed in mainline, they have:
> 
> 	local_bh_disable();
> 
> here.
> 
> I'm surprised we don't have a local_lock_bh() or something to that
> effect.

Turning local_bh_disable() into local_lock_bh(). One side effect would
be that the network driver will be flushed out / waited for completion
during socket write (due to the spin_lock_bh()). Not sure how much fun
all this will bring.
We could try this…

> -- Steve

Sebastian
