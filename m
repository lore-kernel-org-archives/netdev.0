From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Wed, 30 Sep 2009 13:56:12 +0200
Message-ID: <4AC3475C.7000403@hartkopp.net>
References: <200909111648.50902.mb@bu3sch.de> <200909111707.23971.mb@bu3sch.de> <4AAA75CB.6040803@hartkopp.net> <200909111813.35810.mb@bu3sch.de> <4AABCF28.6090505@hartkopp.net> <20090929192928.GF2678@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090929192928.GF2678-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Sat, Sep 12, 2009 at 06:41:12PM +0200, Oliver Hartkopp wrote:
> 
>> i cooked a patch that introduces netif_rx_ti() and fixes up the problems in
>> mac80211 and the CAN subsystem.
> 
> Oliver,
> 
> Are you going to send this patch to Dave?  If you want me to carry
> it instead, please resend it with a proper changelog including a
> Signed-off-by line.  For that matter, Dave will most certainly want
> that as well...

Hello John,

as i wrote here

http://marc.info/?l=linux-netdev&m=125277885910179&w=2

there are currently only three occurrences of checks that use netif_rx() and
netif_rx_ni() depending on in_interrupt().

And regarding the suggested fix from Michael, that checked every(!) netif_rx()
whether it is in interrupt or not, i was unsure if a netif_tx_ti() would make
sense for only three cases?!?

If you think it makes sense, i can post a patch for that ... but:

Indeed it costs some additional investigation to prove whether netif_rx() or
netif_rx_ni() should be used in each case. But IMHO this has to be done before
providing a pump-gun function that solves the problem without thinking if we
are in irq-context or not. I want to avoid that people are using netif_rx_ti()
as some kind of default ...

I don't know how expensive in_interrupt() is, but it IMO should be avoided
when the context for a code section can be determined in another way.

Regards,
Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
