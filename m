From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v3] block/drbd: align properly u64
 in nl messages
Date: Tue, 10 May 2016 21:09:03 +0200
Message-ID: <20160510190902.GF16459@soda.linbit>
References: <20160509131547.GX16459@soda.linbit> <5731A561.6090509@6wind.com>
	<20160510094023.GC16459@soda.linbit>
	<20160510.113949.2077250222547175741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
	philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160510.113949.2077250222547175741.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Tue, May 10, 2016 at 11:39:49AM -0400, David Miller wrote:
> From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
> Date: Tue, 10 May 2016 11:40:23 +0200

excuse me for reordering the original:

> Anyways, back to the topic, can you please just relent and come to
> some kind of agreement about the fix for this alignment bug?

I thought we did?  I'm fine with the "v3",
it even carries my signed-of-by.

Whether or not Nicholas wants to prefix those headers with drbd_,
I don't really care.

> This is taking a very long time and patches are just rotting in
> patchwork with no resolution.  Why would 

Nicholas asked how to go about DRBD,
I suggested to use 0 as a padding attribute,
and after taking a detour, he did. All good.


Rest of original:

> > If we introduce a new config option,
> > we have to add it to the config scanner (one line),
> > define min, max, default and scale (four short defines),
> > and add it to the netlink definition here (one line).
> > Done, rest of the code is generated,
> > both on the kernel side,
> > and on the drbd-utils side used to talk to the kernel.
> > We found that to be very convenient.
> 
> But it entirely misses the core design point of netlink.
> 
> Sender and receive _DO NOT_ need to coordinate at all.  That's the
> whole point.  So tightly coupling such coordination is going to run
> you into all kinds of problems.
> 
> When implemented properly, the sender can emit whatever attributes it
> knows about and can generate, and the receive scans the attributes one
> by one and picks out the ones it understands and processes them.
> 
> If you go against this model
> then you have no clean way to

We don't.
We extend (not violate) that model, so the sender *may* indicate
to the recipient that for some particular attribute, the sender would
rather have an "I don't understand this" return than a silent ignore.
And that we can indicate in the definition of the attributes which ones
are required to make a message meaningful.

> extend things whilst allowing existing software to continue working.

*that* is exactly why we use netlink,
and why we do things with it the way we do.
Actually I think what we are doing there is, comparatively, "elegant".
You obviously don't have to agree.

I could discuss this in more detail,
but I assume you are not really interested,
at least not here and now.

Thanks,

    Lars
