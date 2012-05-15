From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC net-next 0/2] net: Use net_<level>_ratelimit
Date: Tue, 15 May 2012 10:59:25 -0700
Message-ID: <1337104765.7050.24.camel@joe2Laptop>
References: <cover.1336981915.git.joe@perches.com>
	<20120515.134531.530903973750646107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120515.134531.530903973750646107.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-05-15 at 13:45 -0400, David Miller wrote:
> From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> Date: Mon, 14 May 2012 00:56:24 -0700
> 
> > net_ratelimit() like __ratelimit() is too easy to misuse.
> > 
> > Add simplifying macros similar to pr_<level>_ratelimited
> > that combines the test of net_ratelimit and logging.
> > 
> > Joe Perches (2):
> >   net: Add net_ratelimited_function and net_<level>_ratelimited macros
> >   net: Convert net_ratelimit uses to net_<level>_ratelimited
> 
> These look fine to me so I've applied them to net-next and am
> sanity checking the build right now.

OK, but fyi, there's a possible issue with !CONFIG_DEBUG
builds because these patches converted some uses of
	if (net_ratelimit())
		printk(KERN_DEBUG ...
to
	net_dbg_ratelimited()

These messages are no longer emitted when DEBUG isn't defined
and not using dynamic_debug.  I'm not sure that's a real
problem, but it's a difference.

I could produce a net_printk_ratelimited that would keep
the original behavior if necessary.

	net_printk_ratelimited(KERN_DEBUG etc...)

cheers, Joe
