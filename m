From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: BQL crap and wireless
Date: Fri, 26 Aug 2011 16:27:22 -0700
Message-ID: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I've just read this thread:

http://marc.info/?t=131277868500001&r=1&w=2

Since its not linux-wireless I'll chime in here. It seems that you are
trying to write an algorithm that will work for all networking and
802.11 devices. For networking is seems tough given driver
architecture and structure and the hope that all drivers will report
things in a fairly similar way. For 802.11 it was pointed out how we
have varying bandwidths and depending on the technology used for
connection (AP, 802.11s, IBSS) a different number of possible peers
need to be considered. 802.11 faced similar algorithmic complexities
with rate control and the way Andrew and Derek resolved this was to
not assume you could solve this problem and simply test out the water
by trial and error, that gave birth to the minstrel rate control
algorithm which Felix later rewrote for mac80211 with 802.11n support
[1]. Can the BQL algorithm make use of the same trial and error
mechanism and simply try different values and and use EWMA [2] to pick
the best size for the queue ?

[1] http://wireless.kernel.org/en/developers/Documentation/mac80211/RateControl/minstrel
[2] http://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
