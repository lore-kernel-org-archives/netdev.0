From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 21:29:17 +0200
Message-ID: <1491593357.5800.13.camel@sipsolutions.net>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
         <20170407.115315.23470877439489670.davem@davemloft.net>
         <1491591552.5800.1.camel@sipsolutions.net> <20170407190601.GA22991@salvia>
         <1491592185.5800.7.camel@sipsolutions.net> <20170407192134.GA23205@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407192134.GA23205@salvia>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-04-07 at 21:21 +0200, Pablo Neira Ayuso wrote:
> 
> For my usecases in netfilter, the attributes and an specific error
> code should be enough to figure out what is wrong. Will not need
> strings.

Fair enough.

> BTW, we may not have an offset, eg. EINVAL because of missing
> attribute. Given we have different requirements, I would leave it to
> each subsystem to decide what netlink error attributes are specified.
> 
> > (It's ultimately always going to be optional since we'll continue
> > returning errors without *any* extended error information - likely
> > indefinitely - but if we have a wrong attribute, should we always
> > have
> > an offset? Would be nice, but could be difficult in practice)
> > 
> > > We can probably use struct nla_policy to place the extended error
> > > code or the string (as we discussed I don't need string errors,
> > > but
> > > I'm fine if other people find it useful).
> > 
> > I don't think for the error strings really would be useful for
> > nla_parse() or a policy - we can return something generic like
> > "malformed attribute" there as a string, and hopefully point to the
> > attribute/offset from there generically. I just really want to see
> > how
> > to actually do that.
> 
> I think the most flexible way is to pass the container error
> structure to nla_parse() so it sets this for you. This would also
> save tons of "malformed attribute" strings.

Yes, for sure. The thing is we'll probalby have to pass down the
request skb *and* the error struct so that we can get the offset, and
this seems like the generic thing that we really should try to get the
most information generated.

johannes
