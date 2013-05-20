From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/4] net: implement support for low latency
 socket polling
Date: Mon, 20 May 2013 08:29:24 -0700
Message-ID: <1369063764.3301.182.camel@edumazet-glaptop>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	 <20130520101601.14133.874.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130520101601.14133.874.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-20 at 13:16 +0300, Eliezer Tamir wrote:
> Adds a new ndo_ll_poll method and the code that supports and uses it.
> This method can be used by low latency applications to busy poll ethernet
> device queues directly from the socket code. The ip_low_latency_poll sysctl
> entry controls how many cycles to poll. Set to zero to disable.
> 

This changelog lacks a lot of information, see below.

Part of this information was in your 0/4 text, but it wont be included
in the git tree.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---
> 

> +
> +static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
> +{
> +	skb->dev_ref = napi;
> +}
> +
> +static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
> +{
> +	sk->dev_ref = skb->dev_ref;
> +}

I do not see why it's safe to keep a pointer to a napi object without
taking a reference, or something to prevent object being removed.

Using a genid might be enough. (some counter incremented every time a
napi is dismantled)

Alternatively, use a napi_id instead of a pointer.
