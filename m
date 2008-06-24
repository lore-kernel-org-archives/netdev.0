From: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: RFC: always enable MAC80211_RC_PID?
Date: Tue, 24 Jun 2008 15:43:14 +0300
Message-ID: <20080624124311.GC16021@cs181140183.pp.htv.fi>
References: <20080622125553.GB22539@cs181133002.pp.htv.fi> <43e72e890806220804i347b942claae7b725231afcce@mail.gmail.com> <1214298259.8967.260.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1214298259.8967.260.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 24, 2008 at 11:04:19AM +0200, Johannes Berg wrote:
> 
> > You can currently only get away living without it if you are just
> > using iwl3945 or iwl4965 as they provide their own rate control
> > algorithms. In the future if other vendor drivers are added with their
> > own rate control algorithm this list grows.
> 
> FWIW, I would like to see those algorithms be supported as part of
> mac80211 and not be internal like iwlwifi hacked them on, and have some
> sort of feature negotiation between the hardware and the RC algorithm
> when choosing one.

Do we need it as complicated as it is today?

Currently the infrastructure is:
- the default algorithm is built into mac80211
- other algorithms get into their own modules

The implementation of this complicated scheme is horrible
(just look at net/mac80211/Makefile), and anyone adding a new
algorithm will most likely not get it right at his first attempt.

Can we get one of either:
- all selected mac80211 algorithms are built into the mac80211 module or
- all selected mac80211 algorithms (including the default one) are in
  their own modules
?

It wouldn't make any difference today for the CONFIG_EMBEDDED=n case, 
but allows to make things less complicated and will make it easier to 
add additional algorithms.

I'll be glad to provide a patch if one of these is considered 
acceptable.

> johannes

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
