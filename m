From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 12:34:53 -0700 (PDT)
Message-ID: <20170407.123453.846031355373739122.davem@davemloft.net>
References: <1491592185.5800.7.camel@sipsolutions.net>
        <20170407.122223.385211483743191711.davem@davemloft.net>
        <20170407192714.GA23349@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407192714.GA23349@salvia>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Date: Fri, 7 Apr 2017 21:27:14 +0200

> On Fri, Apr 07, 2017 at 12:22:23PM -0700, David Miller wrote:
>> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
>> Date: Fri, 07 Apr 2017 21:09:45 +0200
>> 
>> > On Fri, 2017-04-07 at 21:06 +0200, Pablo Neira Ayuso wrote:
>> >> On Fri, Apr 07, 2017 at 08:59:12PM +0200, Johannes Berg wrote:
>> >> [...]
>> >> > Heh. I think I really want to solve - at least partially -
>> >> > nla_parse()
>> >> > to see that it can be done this way. It'd be nice to even transform
>> >> > all
>> >> > the callers (I generated half of these patches with spatch anyway)
>> >> > to
>> >> > have at least that.
>> >> 
>> >> We can just have a modified version of nla_parse that deals with
>> >> this.
>> > 
>> > Yes, but we need to figure out a good way to have the offset.
>> > 
>> > We also need to see if we want to *force* having the offset. In some
>> > sense that'd be useful, in another it might be very complicated to fill
>> > it in at all times, if for example errors come from lower layers like
>> > drivers.
>> 
>> It has to be optional, some kinds of errors don't have an exact
>> context per-se.
>> 
>> Also another way to look at this is that we're providing a lot of
>> new power and expressability.  So even if only one aspect of the
>> new error reporting is used it's a positive step forward.
>> 
>> So allow offset "0" meaning "unspecified".
> 
> Instead, we can just not send the offset attribute to userspace if
> it's not specified. So missing attribute means "unspecified".

Agreed, not providing the attribute to indicate this is fine.
