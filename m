From: "Simon Barber" <simon@devicescape.com>
Subject: RE: about 802.11i IBSS support
Date: Wed, 25 Oct 2006 12:59:31 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B541F@dhost002-46.dex002.intermedia.net>
References: <20061025154815.GA15348@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jiri Benc" <jbenc@suse.cz>, "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:38033 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S964798AbWJYT7R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 15:59:17 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20061025154815.GA15348@instant802.com>
To: "Jouni Malinen" <jkm@devicescape.com>,
	"Hong Liu" <hong.liu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One area that needs work is the 802.11 qdisc - there is no provision in
the current implementation for queueing certain frames because the
802.11 link is not ready to traqnsmit them yet, while letting other
frames through.

E.G. for normal client mode links it would be nice for the qdisc to
allow management frames and EAPOL frames to an AP through while mid roam
to another AP - but to queue other data frames until EAPOL has
sucessfully completed.

In the IBSS case a similar mechanism could queue data frames sent to a
particular destination, until a key has been negociated with that
destination. 

Indeed if the mechanism is generic the client mode case should be a
subset of the IBSS case.

Simon


-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Jouni Malinen
Sent: Wednesday, October 25, 2006 8:48 AM
To: Hong Liu
Cc: Jiri Benc; netdev
Subject: Re: about 802.11i IBSS support

On Wed, Oct 25, 2006 at 04:54:41PM +0800, Hong Liu wrote:

> I am reading the 802.11i IBSS spec and trying to find if it is OK to 
> add patches to d80211 to support this feature.

Large parts of this will be outside d80211, but yes, I think d80211
should be made ready to support this (mainly in the multiple group keys
area).

> When a STA (say S1) joins in an IBSS network with N STAs, it must 
> negotiate keys with all N STAs.

I don't think it is required to negotiate keys with all STAs of the
network unless it actually needs to communicate with them, i.e., there
may be cases where it is not needed to send or receive data from some of
the nodes.

> We need the following parts to make 802.11i IBSS work:
> 
> 1. for the d80211 part: I don't think there will be much efforts.
>    We may add a group key to each sta_info for decrypting multicast
data from that STA.
>    And in RX path, we need to add code to select the correct group key
for decryption.
>    And also we need to store our own group key used to send multicast
data to others.

This will also include looking into how different WLAN chipsets have
implemented (or will implement) hardware acceleration for such a case.

In addition, there will likely be need for some new kernel-to-userspace
events to notify supplicant/authenticator that communication with a new
target is needed. I don't think the standard has strict requirements on
how this is done and there may be different preferences based on the
application, so adding a generic mechanism for this would be nice.

> 2. wpa_supplicant: this is the big part, we need to implement the
authenticator
>    in it. Not sure how much efforts needed?

This is on my to-do list for wpa_supplicant/hostapd 0.6 branch where it
will be possible to link in part of wpa_supplicant and hostapd together
into a single program. In other words, the authenticator code (both IEEE
802.1X/EAPOL and WPA/WPA2) will be available from hostapd.

-- 
Jouni Malinen                                            PGP id EFC895FA
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
