From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH 9/11] PKT_SCHED: Cleanup cls_set_class
Date: 27 Oct 2004 10:57:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098867450.1813.37.camel@cyan.cph.tpack.net>
References: <20041026222148.GA12289@postel.suug.ch>
	 <20041026222813.GJ12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041026222813.GJ12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-10-27 at 00:28, Thomas Graf wrote:
> +static inline long
> +cls_set_class(struct tcf_proto *tp, unsigned long *clp, 
> +	unsigned long cl)
> +{
> +	unsigned long old_cl;
> +	
> +	qdisc_lock_tree(tp->q->dev);
> +
> +	tcf_tree_lock(tp);
> +	old_cl = __cls_set_class(clp, cl);
> +	tcf_tree_unlock(tp);
> + 
> +	return old_cl;
> +}
> +

This locks once too many.
(And it returns an *unsigned* long.)

-Tommy
