From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next v3] ipv6: log autoconfiguration failures
Date: Sat, 14 Dec 2013 11:39:29 +0100
Message-ID: <20131214103929.GE23563@order.stressinduktion.org>
References: <1386949547-23457-1-git-send-email-dvlasenk@redhat.com> <20131213.175709.414078764436451428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dvlasenk@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131213.175709.414078764436451428.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 13, 2013 at 05:57:09PM -0500, David Miller wrote:
> From: Denys Vlasenko <dvlasenk@redhat.com>
> Date: Fri, 13 Dec 2013 16:45:47 +0100
> 
> > If ipv6 auto-configuration does not work, currently it's hard
> > to track what's going on. This change adds log messages
> > (at debug level) on every code path where ipv6 autoconf fails.
> > 
> > v3: changed pr_debug's to pr_warn's.
> > 
> > Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> 
> I already made it clear I want to see statistics added instead of log
> messages for this.

Hmm... I gave this a bit more thought.

I would go with counters, too. What if we add something like per interface
softerror states. So that we e.g. can see that one protocol had an error on an
interface and it needs attention of an administrator?

E.g.

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP,SOFT_FAIL>

Would catch the eyes more quickly. If counters are implemented we could
do that completly in user space and add that flag as soon as one of the
observed counters are above 0 (and of course, iproute needs colors).

What do you think?
