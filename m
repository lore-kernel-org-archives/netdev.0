From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/4] net: implement support for low latency
 socket polling
Date: Mon, 20 May 2013 00:54:47 -0700 (PDT)
Message-ID: <20130520.005447.972811583292360876.davem@davemloft.net>
References: <20130519102525.12527.83301.stgit@ladj378.jer.intel.com>
	<20130519102533.12527.12991.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donanld.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	andi@firstfloor.org, hpa@zytor.com, eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130519102533.12527.12991.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Sun, 19 May 2013 13:25:33 +0300

> +#ifndef _LINUX_NET_LL_POLL_H
> +#define _LINUX_NET_LL_POLL_H
> +#ifdef CONFIG_INET_LL_RX_POLL

Please put an empty line before the final ifdef test here.

> +static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
> +{
> +		sk->dev_ref = skb->dev_ref;
	^^^

One tab too many.

> +#else /* CONFIG_INET_LL_RX_FLUSH */
> +
> +#define sk_valid_ll(sk) 0
> +#define sk_poll_ll(sk, nonblock) do {} while (0)
> +#define skb_mark_ll(napi, skb) do {} while (0)
> +#define sk_mark_ll(sk, skb) do {} while (0)

Make these inline functions too, so that even if
CONFIG_INET_LL_RX_POLL is disabled, the arguments and return values
are still properly type checked.

>  {
>  	struct socket *sock;
> +	unsigned int poll_result;

Please order local variable declarations from longest line to
shortest line.

> +	    !(poll_result & (POLLRDNORM | POLLERR | POLLRDHUP | POLLHUP))) {
> +
> +		struct sock *sk = sock->sk;

Please remove the empty line before the variable declaration.
