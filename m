From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel 3.7.2 strange warning and short system hang
Date: Wed, 20 Feb 2013 11:30:19 -0800
Message-ID: <1361388619.19353.221.camel@edumazet-glaptop>
References: <5124F57A.6080908@enas.net>
	 <1361379176.19353.187.camel@edumazet-glaptop>
	 <20130220.125715.2150428275032134361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bind@enas.net, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130220.125715.2150428275032134361.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-20 at 12:57 -0500, David Miller wrote:

> I've seen this pattern on several occasions and I have to wonder...
> 
> Do we really require, therefore, every NAPI driver to use dev_kfree_skb_any()
> in it's TX reclaim if it supports netpoll?
> 
> That seems completely bogus.
> 


> netpoll is supposed to provide an execution environment when it invokes
> ->poll() that is identical to the normal NAPI execution.  If that would
> be true, then this change above would be completely unnecessary.
> 
> We need to figure out what is the case here, and audit all the NAPI
> drivers to make sure they do the right thing once we know what the
> right thing actually is.

netpoll directly calls n->poll()

(poll_napi() -> poll_one_napi() -> napi->poll(napi, budget) )

Presumably it should not do that if running in interrupt context.
