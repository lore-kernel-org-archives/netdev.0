From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Mon, 06 Jun 2011 08:57:59 +0200
Message-ID: <4DEC7A77.6010109@ahsoftware.de>
References: <4DE93422.3070000@ahsoftware.de>	 <1307129642.2600.2.camel@edumazet-laptop>  <4DE93B31.8040700@ahsoftware.de> <1307130914.2600.12.camel@edumazet-laptop> <4DEA1F5F.4070707@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DEA1F5F.4070707@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Am 04.06.2011 14:04, schrieb Alexander Holler:

> Anyway, I've used the broken way of not using git send-email because I'm
> unsure if the solution I've offered is the best one. I'm lacking the
> knowledge about what cow_metrics() does, what it is used for, and what,
> if any, pre- or post-requisites are needed to use
> dst_cow_metrics_generic().
>
> I can only say that my solution seems to work here, the machine comes up
> without an oops and I didn't have seen any other problems while using
> the bridge (which surely doesn't say anything, e.g. I'm not sure if my
> use of dst_cow_metrics_generic() may introduce a mem leak or similiar,
> it doesn't look so, but who knows).

After having a second look at dst_cow_metrics_generic(), it seems my 
patch does introduce a small mem leak which occurs when the bridge will 
be build as a module and the module gets unloaded. Then the static 
struct dst_ops fake_dst_ops disappears and with that the memory 
allocated by dst_cow_metrics_generic() is lost. I'm not sure which of 
the dst*-functions should be called before the module gets unloaded. 
Maybe someone with a deeper knowledge of the that stuff could have a 
look at that.
Or maybe just changing the true in the call to dst_cow_metrics_generic() 
in br_netfilter_rtable_init() to false instead of adding 
dst_cow_metrics_generic() to fake_dst_ops() is an alternative. As I 
said, I don't know what that metric-stuff does and what it is used for.

Regards,

Alexander
