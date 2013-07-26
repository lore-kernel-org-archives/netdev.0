From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: changing dev->needed_headroom/needed_tailroom?
Date: Fri, 26 Jul 2013 16:50:10 +0200
Message-ID: <1374850210.8248.59.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Does it seem reasonable to change dev->needed_headroom and
dev->needed_tailroom on the fly?

We currently set needed_headroom to the max of what we need, but we
could do better like making it depend on the interface type (e.g. only
asking for mesh space on mesh interfaces). This would be done only when
the interface isn't connected, I can't promise it would be down but the
carrier would be off.

Another thing we might want to do is change it according to the
currently configured crypto (this would also affect
dev->needed_tailroom) since we actually only need tailroom when TKIP is
used. This could might be done on the fly, but could also be done when
the carrier is still down during connection establishment (which would
not be a complete optimisation but still be better than what we have
now)

Thoughts?

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
