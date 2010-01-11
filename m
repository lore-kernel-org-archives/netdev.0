From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: REGRESSION for RT2561/RT61 in 2.6.33
Date: Mon, 11 Jan 2010 09:54:20 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1001110947350.2873-100000@iolanthe.rowland.org>
References: <4B201D67.8000607@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel development list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B201D67.8000607-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Gertjan:

Sorry to bother you again, but I have run across a new bug affecting
my rt2561s card.  It appeared in 2.6.33-rc1 and is still present in 
-rc3.  (This is with CONFIG_CFG80211_DEFAULT_PS disabled, not that it 
should make any difference now.)

The card doesn't work.  Although the firmware load appears to
succeed, "iwconfig wlan0" says no wireless extensions present.

The only clue I can offer is that "rmmod rt61pci" hangs in 
wiphy_unregister() during the wait_event() loop near the start, because 
rdev->opencount is equal to -1.  This suggests a refcounting imbalance 
of some sort.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
