From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v2] ipvlan: Initial check-in of the IPVLAN driver.
Date: Thu, 20 Nov 2014 22:38:18 -0800
Message-ID: <CAF2d9jh6X=3tExxozL2zQWcQzSdCFiyvO1=gXDzHOtvFDmhwLA@mail.gmail.com>
References: <1416205634-26611-1-git-send-email-maheshb@google.com>
 <20141118.155437.1582768084232091503.davem@davemloft.net> <CAF2d9jjrN4cDmtN_yKTe0BS+cAqE=hqgsT_6mOEBuMTTPOaPRg@mail.gmail.com>
 <1416532836.7215.13.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>, brandon.philips@coreos.com,
	xemul@parallels.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:51552 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbaKUGij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 01:38:39 -0500
Received: by mail-vc0-f177.google.com with SMTP id ij19so2030714vcb.22
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 22:38:38 -0800 (PST)
In-Reply-To: <1416532836.7215.13.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 5:20 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Tue, 2014-11-18 at 21:27 -0800, Mahesh Bandewar wrote:
>> On Tue, Nov 18, 2014 at 12:54 PM, David Miller <davem@davemloft.net> wrote:
>> >
>> > From: Mahesh Bandewar <maheshb@google.com>
>> > Date: Sun, 16 Nov 2014 22:27:14 -0800
>> >
>> > > +/* Define IPVL_DEBUG and set the appropriate dbg_level for debugging. */
>> > > +#ifdef       IPVL_DEBUG
>> > > +/*
>> > > + * 1 : non-datapath debugging
>> > > + * 2 : Custom
>> > > + * 3 : function enters and exists.
>> > > + * 4 : printk in data path (be careful!)
>> > > + */
>> > > +#define IPVL_DBG_LEVEL 1
>> > > +#define ipvlan_dbg(level, msg...)    do { \
>> > > +                                             if (level <= IPVL_DBG_LEVEL) \
>> > > +                                             printk(KERN_DEBUG msg); \
>> > > +                                     } while (0)
>> > > +#else
>> > > +#define ipvlan_dbg(level, msg...) do { ; } while (0)
>> > > +#endif
>> >
>> > The day of having code use custom local debug logging facilities is long
>> > gone, please use a standard mechanism for this rather than home cooked
>> > reimplementations.
>> >
>> Do you mean pr_err() / pr_warn() / pr_debug() etc.? or something else?
> [...]
>
> There are also netdev_err() etc. for logging with a net device as
> context.
>
> You can use the netif_err(), netif_dbg() etc. functions and implement
> the ethtool {get,set}_msglevel operations to allow turning on and off
> broad classes of log messages.
>
> Finally, if CONFIG_DYNAMIC_DEBUG is enabled then debug logging messages
> can be turned on and off at run-time (individually or by function, file
> or module).
>
Thanks Ben, I'll try using netif_dbg().

> Ben.
>
> --
> Ben Hutchings
> Beware of bugs in the above code;
> I have only proved it correct, not tried it. - Donald Knuth
