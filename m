From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v2] block/drbd: use
	nla_put_u64_64bit()
Date: Wed, 4 May 2016 11:05:30 +0200
Message-ID: <20160504090529.GJ16459@soda.linbit>
References: <57286F49.8050107@6wind.com>
	<1462268358-19044-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160503100644.GE16459@soda.linbit>
	<20160503.120556.1317913903199470646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
	philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160503.120556.1317913903199470646.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://lists.linbit.com/mailman/options/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linbit.com/pipermail/drbd-dev>
List-Post: <mailto:drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
List-Help: <mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=help>
List-Subscribe: <http://lists.linbit.com/mailman/listinfo/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=subscribe>
Sender: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
Errors-To: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 03, 2016 at 12:05:56PM -0400, David Miller wrote:
> From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
> Date: Tue, 3 May 2016 12:06:44 +0200
> 
> > Please just NOT use an additional "field",
> > but always use 0 to pad.
> 
> You can't, it doesn't work.

I did, and it *did* work.
At least, it appeared to.

I'm not talking about every user of netlink out there.
That I don't know. But specifically for DRBD netlink,
from what my experiments tell me, it works just fine.

> We are adding a new field to every netlink protocol family that has
> this alignment problem.

We don't have an "alignment problem" there, btw.
Last time I checked, we did work fine without this alignment magic,
we already take care of that, yes, even on affected architectures.

On Tue, May 03, 2016 at 12:06:52PM -0400, David Miller wrote:
> From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
> Date: Tue, 3 May 2016 12:06:44 +0200
> 
> > Whereas using some arbitrary value will be wrong,
> > and will needlessly break userland.
> 
> It cannot break userland.

It can, if those tags have been used already.
There is DRBD out-of-tree as well,
it usually is ahead of in-tree DRBD.

But yes, I could obviously check and assign and reserve some
not-yet-used tag to all of them.

I don't see why, though, given that 0 (appearently) works fine.

Can you elaborate why and how that does not work?

	Lars
