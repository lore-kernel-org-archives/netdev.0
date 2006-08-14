From: "Simon Barber" <simon@devicescape.com>
Subject: RE: wlan#ap seems bogus
Date: Mon, 14 Aug 2006 11:53:41 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165ACBF@dhost002-46.dex002.intermedia.net>
References: <44E082DA.8070606@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jouni Malinen" <jkm@devicescape.com>, "Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:43098 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932307AbWHNSxd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 14:53:33 -0400
Content-class: urn:content-classes:message
in-reply-to: <44E082DA.8070606@sipsolutions.net>
To: "Johannes Berg" <johannes@sipsolutions.net>,
	<netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The purpose of the wlap0ap or wlap0mgmt interface is to communicate
between hostapd/wpa_supplicant and the kernel. What travels over this
interface is not quite pure 802.11 management frames - there is some
meta-data with each frame, and a few special case messages. E.G.
transmitted frames are returned back to user space to indicate
successful transmission (required so that the MLME state machine can be
correctly implemented in user space). I believe these messages form a
special management protocol between the kernel and user space, and that
netlink would be the best solution for this link. Switching to netlink
would allow these bogus 'network' interfaces to be removed alltogether.
Unfortunately I don't currently have the time to put together a patch to
do this.

Simon


-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Johannes Berg
Sent: Monday, August 14, 2006 7:04 AM
To: netdev@vger.kernel.org
Cc: Jouni Malinen; Jiri Benc
Subject: Re: wlan#ap seems bogus

Johannes Berg wrote:
> Hence, I think it ought to be named 'wlan#mgmt' instead.

I see it's actually called wmgmt# now. Sorry. The rest of this mail
still holds though.

johannes
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
