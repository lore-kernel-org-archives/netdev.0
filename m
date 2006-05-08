From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netdev: hotplug napi race cleanup
Date: Mon, 8 May 2006 09:54:58 -0700
Message-ID: <20060508095458.0debd022@localhost.localdomain>
References: <20060421102503.4e44eb28@localhost.localdomain>
	<E1FX5zQ-000177-00@gondolin.me.apana.org.au>
	<20060424152341.094b72d8@localhost.localdomain>
	<20060506.180947.35317492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, patrakov@ums.usu.ru,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63161 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932422AbWEHQzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 12:55:13 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060506.180947.35317492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 06 May 2006 18:09:47 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Mon, 24 Apr 2006 15:23:41 -0700
> 
> > This follows after the earlier two patches.
> > 
> > Change the initialization of the class device portion of the net device
> > to be done earlier, so that any races before registration completes are
> > harmless.  Add a mutex to avoid changes to netdevice during the
> > class device registration. 
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> I'm not going to apply this patch and instead request that we think
> about why this problem exists in the first place.
> 
> This patch is even stronger evidence that doing the sysfs registry in
> the todo list processing is wrong.  If you can legally do this while
> holding the rtnl semaphore, you can just as equally do it inside of
> register_netdevice() which is where it truly belongs.
> 
> Then you can handle errors properly, unwind the state, and return the
> error to the caller instead of just losing the error and leaving the
> device in a half-registered state.

The issue is are there network devices that can't sleep during
register_netdevice?
