From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH] wireless: change cfg80211 regulatory domain info as
 debug messages
Date: Mon, 23 Nov 2015 09:37:40 +0800
Message-ID: <20151123013740.GA27383@dhcp-128-32.nay.redhat.com>
References: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
 <20151115192547.3fd1b3cc@mir>
 <1448020533.3141.27.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Lippers-Hollmann <s.l-h@gmx.de>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448020533.3141.27.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/20/15 at 12:55pm, Johannes Berg wrote:
> On Sun, 2015-11-15 at 19:25 +0100, Stefan Lippers-Hollmann wrote:
> > Hi
> > 
> > On 2015-11-15, Dave Young wrote:
> > > cfg80211 module prints a lot of messages like below. Actually
> > > printing once is acceptable but sometimes it will print again and
> > > again, it looks very annoying. It is better to change these detail
> > > messages to debugging only.
> > 
> > It is a lot of info, easily repeated 3 times on boot, but it's also
> > the only real chance to determine why you ended up with the
> > regulatory domain settings you got, rather than just the values
> > itself. Given that a lot (most?) of officially shipping wireless
> > devices are misconfigured (wrong EEPROM regdom settings for the
> > region they're sold in) and considering that the limits can even
> > change at runtime (IEEE 802.11d), it is imho quite important not just
> > to be able what the current restrictions (iw reg get) are, but also
> > why the kernel settled on those.
> > 
> 
> Hm. I kinda sympathize with both points of view here, not sure what to
> do.
> 
> Maybe we could skip this for the world regdomain only? It doesn't
> really change, and we typically don't care that much for it? That'd
> probably get rid of most of the lines already.
> 
> Alternatively, perhaps the internal computations should be more
> transparently visible through some other mechanism?
> 

If they are for debugging purpose I would like to see them as pr_debug
or something in debugfs. Especially for printks which will not only
being called on initialization phase.

Seems there're a lot of other wireless messages. Should we refactor 
them as well? I still did not get chance to see where is the code.
(My wireless driver being used is iwlwifi)

# uptime
 09:36:31 up 17 days, 19:17, 11 users,  load average: 0.26, 0.25, 0.17

#dmesg|grep wlp3s0|wc
   4868   54014  404187

# dmesg|grep "Limiting TX power"|wc
   4128   49600  360052

Thanks
Dave
