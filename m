From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 21:09:45 +0200
Message-ID: <1491592185.5800.7.camel@sipsolutions.net>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
         <20170407.115315.23470877439489670.davem@davemloft.net>
         <1491591552.5800.1.camel@sipsolutions.net> <20170407190601.GA22991@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407190601.GA22991@salvia>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-04-07 at 21:06 +0200, Pablo Neira Ayuso wrote:
> On Fri, Apr 07, 2017 at 08:59:12PM +0200, Johannes Berg wrote:
> [...]
> > Heh. I think I really want to solve - at least partially -
> > nla_parse()
> > to see that it can be done this way. It'd be nice to even transform
> > all
> > the callers (I generated half of these patches with spatch anyway)
> > to
> > have at least that.
> 
> We can just have a modified version of nla_parse that deals with
> this.

Yes, but we need to figure out a good way to have the offset.

We also need to see if we want to *force* having the offset. In some
sense that'd be useful, in another it might be very complicated to fill
it in at all times, if for example errors come from lower layers like
drivers.

(It's ultimately always going to be optional since we'll continue
returning errors without *any* extended error information - likely
indefinitely - but if we have a wrong attribute, should we always have
an offset? Would be nice, but could be difficult in practice)

> We can probably use struct nla_policy to place the extended error
> code or the string (as we discussed I don't need string errors, but
> I'm fine if other people find it useful).

I don't think for the error strings really would be useful for
nla_parse() or a policy - we can return something generic like
"malformed attribute" there as a string, and hopefully point to the
attribute/offset from there generically. I just really want to see how
to actually do that.

johannes
