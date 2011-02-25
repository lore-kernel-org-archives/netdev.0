From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2011-02-22
Date: Fri, 25 Feb 2011 16:36:18 -0300
Message-ID: <20110225193618.GB2107@joana>
References: <20110222215229.GJ12153@tuxdriver.com>
 <20110224.224344.104068328.davem@davemloft.net>
 <20110225.111500.59674472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110225.111500.59674472.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

* David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> [2011-02-25 11:15:00 -0800]:

> From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Date: Thu, 24 Feb 2011 22:43:44 -0800 (PST)
> 
> > From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> > Date: Tue, 22 Feb 2011 16:52:30 -0500
> > 
> >> Here is the latest batch of wireless bits intended for 2.6.39.  It seems
> >> I neglected to send a pull request last week, so this one is a bit big
> >> -- I apologize!
> >> 
> >> This includes a rather large batch of bluetooth bits by way of Gustavo.
> >> It looks like a variety of bits, including some code refactoring, some
> >> protocol support enhancements, some bugfixes, etc. -- nothing too
> >> unusual.
> >> 
> >> Other items of interest include a new driver from Realtek, some ssb
> >> support enhancements, and the usual sort of updates for mac80211 and a
> >> variety of drivers.  Also included is a wireless-2.6 pull to resolve
> >> some build breakage.
> >> 
> >> Please let me know if there are problems!
> > 
> > Pulled, thanks a lot John.
> 
> John a few things:
> 
> 1) I had to add some vmalloc.h includes to fix the build on sparc64,
>    see commit b08cd667c4b6641c4d16a3f87f4550f81a6d69ac in net-next-2.6
> 
> 2) Something is screwey with the bluetooth config options now.
> 
>    I have an allmodconfig tree, and when I run "make oldconfig" after
>    this pull, BT_L2CAP and BT_SCO both prompt me, claiming that they
>    can only be built statically.
> 
>    I give it 'y' just to make it happen, for both, and afterways no
>    matter how many times I rerun "make oldconfig" I keep seeing things
>    like this in my build:
> 
> scripts/kconfig/conf --silentoldconfig Kconfig
> include/config/auto.conf:986:warning: symbol value 'm' invalid for BT_SCO
> include/config/auto.conf:3156:warning: symbol value 'm' invalid for BT_L2CAP
> 
>    First, what the heck is going on here?  Second, why the heck can't these
>    non-trivial pieces of code be built modular any more?

We now have L2CAP and SCO built-in in the main bluetooth.ko module.

> 
>    You can't make something "bool", have it depend on something that
>    might be modular, and then build it into what could in fact be a
>    module.  That's exactly what the bluetooth stuff seems to be doing
>    now.

Seems I did the Kconfig change wrong, I'll fix it ASAP and send it to you
guys.

-- 
Gustavo F. Padovan
http://profusion.mobi
