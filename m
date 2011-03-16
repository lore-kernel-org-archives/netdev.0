From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: net-next-2.6 status...
Date: Wed, 16 Mar 2011 18:13:39 +0000
Message-ID: <1300299219.2811.7.camel@bwh-desktop>
References: <20110316.000251.189704695.davem@davemloft.net>
	 <20110316073803.GB2780@psychotron.redhat.com>
	 <20110316084022.GA2845@psychotron.brq.redhat.com>
	 <20110316.104236.104065822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, netfilter-devel@vger.kernel.org,
	eric.dumazet@gmail.com, linville@tuxdriver.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110316.104236.104065822.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-03-16 at 10:42 -0700, David Miller wrote:
> From: Jiri Pirko <jpirko@redhat.com>
> Date: Wed, 16 Mar 2011 09:40:23 +0100
> 
> > Wed, Mar 16, 2011 at 08:38:03AM CET, jpirko@redhat.com wrote:
> >>Wed, Mar 16, 2011 at 08:02:51AM CET, davem@davemloft.net wrote:
> >>>From: Jiri Pirko <jpirko@redhat.com>
> >>>Date: Wed, 16 Mar 2011 07:50:09 +0100
> >>>
> >>>>>Jiri, I know there is your patch set there, but I think you and Changli
> >>>>>still need to go back and forth one more time wrt. orig_dev semantics.
> >>>>>Since you have been posting this patch set for some time I'm still
> >>>>>willing to apply it for this merge window, but please make haste and
> >>>>>work out the remaining discussion.  Thank you.
> >>>> 
> >>>> Dave, you can apply the rest of the series and leave only the first
> >>>> patch (af_packet) out. There's no dependency. We will figure out things
> >>>> around origdev later.
> >>>
> >>>I was about to do that but I've found other problems.
> >>>
> >>>You cannot make the modifications you make to linux/if.h, those
> >>>interface flags are visible to userspace.
> >>
> >>What do you suggest? To remove unused flags and leave gaps there or to
> >>not to remove the flags at all?
> > 
> > Well, the following comment:
> > <quote>
> > /* Private (from user) interface flags (netdevice->priv_flags). */
> > </quote>
> > leads me to think that these flags should not be used by userspace.
> > So maybe it may not be problem to change those values.
> 
> Comments don't block user applications from using defines we expose
> to them.  The person who was wise enough to write that comment should
> have also been wise enough to add appropriate __KERNEL__ protection
> to the definitions.

Though, in this case, the priv_flags are not in any way visible to
user-space, so it would be quite hard to find a use for them!

> They were not, therefore we are stuck with them forever.

So should we also expose struct net_device_stats again?  During the
introduction to 64-bit stats I changed and un-exported the definition,
then later had to revert the definition but left it un-exported.  This
broke compilation of iproute2, though in the process it revealed an
existing bug: <http://thread.gmane.org/gmane.linux.network/169764>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

