From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Wed, 19 Nov 2014 00:48:23 -0500 (EST)
Message-ID: <20141119.004823.1741757230646192765.davem@davemloft.net>
References: <1416205634-26611-1-git-send-email-maheshb@google.com>
	<20141118.155437.1582768084232091503.davem@davemloft.net>
	<CAF2d9jjrN4cDmtN_yKTe0BS+cAqE=hqgsT_6mOEBuMTTPOaPRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maze@google.com,
	chavey@google.com, thockin@google.com, brandon.philips@coreos.com,
	xemul@parallels.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbaKSFsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 00:48:25 -0500
In-Reply-To: <CAF2d9jjrN4cDmtN_yKTe0BS+cAqE=hqgsT_6mOEBuMTTPOaPRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Tue, 18 Nov 2014 21:27:48 -0800

> On Tue, Nov 18, 2014 at 12:54 PM, David Miller <davem@davemloft.net> wrote:
>>
>> From: Mahesh Bandewar <maheshb@google.com>
>> Date: Sun, 16 Nov 2014 22:27:14 -0800
>>
>> > +/* Define IPVL_DEBUG and set the appropriate dbg_level for debugging. */
>> > +#ifdef       IPVL_DEBUG
>> > +/*
>> > + * 1 : non-datapath debugging
>> > + * 2 : Custom
>> > + * 3 : function enters and exists.
>> > + * 4 : printk in data path (be careful!)
>> > + */
>> > +#define IPVL_DBG_LEVEL 1
>> > +#define ipvlan_dbg(level, msg...)    do { \
>> > +                                             if (level <= IPVL_DBG_LEVEL) \
>> > +                                             printk(KERN_DEBUG msg); \
>> > +                                     } while (0)
>> > +#else
>> > +#define ipvlan_dbg(level, msg...) do { ; } while (0)
>> > +#endif
>>
>> The day of having code use custom local debug logging facilities is long
>> gone, please use a standard mechanism for this rather than home cooked
>> reimplementations.
>>
> Do you mean pr_err() / pr_warn() / pr_debug() etc.? or something else?

And netdev_dbg(), etc.

And about sysfs, we're not having two ways to do the same exact
thing.  Whatever functionality you want to provide, implement it
via netlink and that's the end of it.
