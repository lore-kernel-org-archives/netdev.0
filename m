From: "Leisner, Martin" <Martin.Leisner@xerox.com>
Subject: using KERN_ERR in IPv6
Date: Wed, 14 Jan 2009 16:28:28 -0500
Message-ID: <556445368AFA1C438794ABDA8901891C0A5A07D6@USA0300MS03.na.xerox.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <martyleisner@yahoo.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wvmler2.mail.xerox.com ([13.8.138.217]:59865 "EHLO
	wvmler2.mail.xerox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759590AbZANVyE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 16:54:04 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're using 2.6.20 (but its also in 2.6.28).

In ipv6/ndisc.c:ndisc_router_discover() (cut and pasted from 2.6.20)
         if (rt == NULL && lifetime) {
                ND_PRINTK3(KERN_DEBUG
                           "ICMPv6 RA: adding default router.\n");

                rt = rt6_add_dflt_router(&skb->nh.ipv6h->saddr,
skb->dev, pref);
                if (rt == NULL) {
                        ND_PRINTK0(KERN_ERR
                                   "ICMPv6 RA: %s() failed to add
default route.\n",
                                   __FUNCTION__);
                        in6_dev_put(in6_dev);
                        return;
                }

                neigh = rt->rt6i_nexthop;
                if (neigh == NULL) {
                        ND_PRINTK0(KERN_ERR
                                   "ICMPv6 RA: %s() got default router
without neighbour.\n",
                                   __FUNCTION__);
                        dst_release(&rt->u.dst);
                        in6_dev_put(in6_dev);
                        return;
                }

My understanding is when running again a Microsoft 2003 server, it has a
bug  which excites  the message "failed to add default route" which is
normally echoed to the console which is quite cumbersome.

With Microsoft 2007 servers, the problem goes away.

But why would a protocol problem be a KERN_ERR (maybe KERN_INFO?)

Comments?

marty


