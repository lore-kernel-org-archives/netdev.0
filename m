From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: about 802.11i IBSS support
Date: Wed, 25 Oct 2006 08:48:15 -0700
Message-ID: <20061025154815.GA15348@instant802.com>
References: <1161766481.8668.38.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-27.dex002.intermedia.net ([64.78.21.112]:30621 "EHLO
	dhost002-27.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751725AbWJYPsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 11:48:30 -0400
To: Hong Liu <hong.liu@intel.com>
Content-Disposition: inline
In-Reply-To: <1161766481.8668.38.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2006 at 04:54:41PM +0800, Hong Liu wrote:

> I am reading the 802.11i IBSS spec and
> trying to find if it is OK to add patches to d80211 to support this feature.

Large parts of this will be outside d80211, but yes, I think d80211
should be made ready to support this (mainly in the multiple group keys
area).

> When a STA (say S1) joins in an IBSS network with N STAs,
> it must negotiate keys with all N STAs.

I don't think it is required to negotiate keys with all STAs of the
network unless it actually needs to communicate with them, i.e., there
may be cases where it is not needed to send or receive data from some of
the nodes.

> We need the following parts to make 802.11i IBSS work:
> 
> 1. for the d80211 part: I don't think there will be much efforts.
>    We may add a group key to each sta_info for decrypting multicast data from that STA.
>    And in RX path, we need to add code to select the correct group key for decryption.
>    And also we need to store our own group key used to send multicast data to others.

This will also include looking into how different WLAN chipsets
have implemented (or will implement) hardware acceleration for such a
case.

In addition, there will likely be need for some new kernel-to-userspace
events to notify supplicant/authenticator that communication with a new
target is needed. I don't think the standard has strict requirements on
how this is done and there may be different preferences based on the
application, so adding a generic mechanism for this would be nice.

> 2. wpa_supplicant: this is the big part, we need to implement the authenticator
>    in it. Not sure how much efforts needed?

This is on my to-do list for wpa_supplicant/hostapd 0.6 branch where it
will be possible to link in part of wpa_supplicant and hostapd together
into a single program. In other words, the authenticator code (both IEEE
802.1X/EAPOL and WPA/WPA2) will be available from hostapd.

-- 
Jouni Malinen                                            PGP id EFC895FA
