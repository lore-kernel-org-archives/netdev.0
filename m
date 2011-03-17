From: Christoph Lameter <cl@linux.com>
Subject: Re: Poll about irqsafe_cpu_add and others
Date: Thu, 17 Mar 2011 10:18:15 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1103171016270.12540@router.home>
References: <1300371834.6315.93.camel@edumazet-laptop> <20110317.081420.71114992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110317.081420.71114992.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2011, David Miller wrote:

>
> I had been meaning to bring this up from another perspective.
>
> In networking, we often only ever access objects in base or
> BH context.  Therefore in BH context cases we can do just
> normal counter bumps without any of the special atomic or
> IRQ disabling code at all.

We have the __ functions for that purpose. __this_cpu_inc f.e. falls back
to a simply ++ operation if the arch cannot provide something better.
irqsafe_xx are only used if the context does not provide any protection
and if there is the potential of the counter being incremented from an
interrupt context.
