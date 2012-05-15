From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC net-next 0/2] net: Use net_<level>_ratelimit
Date: Tue, 15 May 2012 20:40:45 +0200
Message-ID: <1337107245.15553.14.camel@jlt3.sipsolutions.net>
References: <20120515.134531.530903973750646107.davem@davemloft.net>
	<1337104765.7050.24.camel@joe2Laptop>
	<1337106430.15553.6.camel@jlt3.sipsolutions.net>
	<20120515.142922.1434224550630736456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120515.142922.1434224550630736456.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Tue, 2012-05-15 at 14:29 -0400, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Tue, 15 May 2012 20:27:10 +0200
> 
> > On Tue, 2012-05-15 at 10:59 -0700, Joe Perches wrote:
> > 
> >> OK, but fyi, there's a possible issue with !CONFIG_DEBUG
> >> builds because these patches converted some uses of
> >> 	if (net_ratelimit())
> >> 		printk(KERN_DEBUG ...
> >> to
> >> 	net_dbg_ratelimited()
> >> 
> >> These messages are no longer emitted when DEBUG isn't defined
> >> and not using dynamic_debug.  I'm not sure that's a real
> >> problem, but it's a difference.
> >> 
> >> I could produce a net_printk_ratelimited that would keep
> >> the original behavior if necessary.
> >> 
> >> 	net_printk_ratelimited(KERN_DEBUG etc...)
> > 
> > Btw, what would the difference be to just plain printk_ratelimited()?
> 
> printk_ratelimited() drops a local ratelimit cookie into each call-site,
> whereas we have a global one for the networking which these new interfaces
> use.
> 
> Joe explained this completely in his 0/2 patch posting.

I don't see that explicitly mentioned, but it doesn't matter much
anyway.

In the mac80211 case, messages are warnings/hints to the user, we just
don't want them to flood the logs too much. I'd rather have that kind of
change (limit cookie per callsite) in the rate limiting semantics than
the change in the when it gets printed at all.

I simply feel that obscuring the debugging even further wouldn't be a
good thing to do right now. I'd rather have somebody convert all of it
to the new debugging infrastructure but that seems a lot more effort
than changing these back to something that isn't impacted by dynamic
printk.

johannes
