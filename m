From: Dan Williams <dcbw@redhat.com>
Subject: Re: Where Linux 802.11x support needs work
Date: Wed, 26 Jan 2005 13:03:31 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0501261253520.9464@devserv.devel.redhat.com>
References: <20050126024039.GA25326@bougret.hpl.hp.com>
 <Pine.LNX.4.58.0501252224000.4275@devserv.devel.redhat.com> <41F743F6.2020008@web.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dan Williams <dcbw@redhat.com>, Jean Tourrilhes <jt@hpl.hp.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Renzmann <mrenzmann@web.de>
In-Reply-To: <41F743F6.2020008@web.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 26 Jan 2005, Michael Renzmann wrote:
> 
> Dan Williams wrote:
> > madwifi: doesn't seem to implement SIOCGIWSTATS
> 
> It does. The SIOCGIWSTATS is used in tools/athstats.c (line 195 in 
> current CVS) for example to get the rssi (via qual.qual).

Except then there's no handler for it in the ath_handlers[] array:

/Users/dan/Desktop/madwifi> grep -r "SIOCGIWSTATS" *
ath/if_ath.c:   (iw_handler) NULL /* kernel code */, /* SIOCGIWSTATS */
tools/athstats.c:       if (ioctl(s, SIOCGIWSTATS, &wrq) < 0)

That makes it essentially useless for using with the Linux Wireless 
Extensions API (unless the ioctl() somehow redirets calls to SIOCGIWSTATS 
to the dev->get_wireless_stats function?).  In any case, it should be as 
simple as adding the ath_iw_getstats() function to that line in 
ath/if_ath.c in the ath_handlers[] array.  So I guess no fundamental 
problems there, should be a 20 second fix.

> >>>o  Ad-Hoc mode support is quite flaky or absent from most drivers
> >>	Low priority for most vendors, firwmares are only lightly tested.
> > Yeah, I don't expect much to happen here but it would be nice.  FWIW, at 
> > least madwifi and atmel seem to work OK here.
> 
> Madwifi unfortunately has some known problems in Ad-hoc implementation. 
> Someone worked on that, but the patches have not been sent in as far as 
> I can tell.

It actually seems to perform fairly well already.  The only problems I 
noticed were that whne you set the card into Ad-hoc mode and set the ESSID 
on the card, it dropts to a bitrate of 0 and performance is terrible.  
When you explicitly set a bitrate of 11Mbps or some other value on the 
card the it works fine.  I think the card just gets a bit confused as to 
what bitrate to use when doing Ad-hoc mode.

> >>	Note that various other people have their own todo list. Jeff
> >>also has things he has in minds. I have (few) patches on my web
> >>pages. Driver authors also have their wishes.
> > True, but I'm not sure how many of those wishes/todo lists are actually 
> > well-known or public.  I don't really see any great momentum in the Linux 
> > 802.11x world, but more a hodge-podge of improvements.  I was hoping that 
> > the post today could help  direct a bit more attention and effort at Linux 
> > 802.11x stuff so we could try to clean it up and improve it.
> 
> How about setting up a project that cares of finding, defining and 
> implementing such quasi-standards in the Linux 802.11 world? Most things 
> are very WLAN specific, so I think netdev isn't the best place to 
> discuss them. Of course this only works IMO when many (if not all) of 
> the wlan driver authors join in and help out.

This would probably be a very good thing :)

Dan
