From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: writing timestamps to outgoing packets
Date: Tue, 16 Jun 2015 11:15:50 +0200
Message-ID: <1434446150.2337.17.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

For MA-USB (media-agnostic USB, but specifically we're working on doing
it over 802.11 wifi) there's a need to write a timestamp to outgoing
packets at a specific offset inside the packet.

Unfortunately, it's not that we have to write the timestamp of the
previous packet or similar which could be achieved with the existing
timestamp service, but the packet that's being sent.

We'll probably have to use LLC, so ideally we could use the LLC
framework (though - it seems to have some bugs - is anyone using it?),
but that obviously makes it difficult to pass enough information to the
low-level driver to enable the timestamping (which is done in
firmware/hardware.)

Does anyone have any thoughts? Should we try to mark the packet somehow?
But all ways I can find could possibly conflict with other markers. Or
perhaps we should add a generic "write timestamp to packet" framework?

I'm a bit surprised that nobody else has had this need before - or
perhaps they did and solved the problem in a different way?

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
