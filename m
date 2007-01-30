From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: Hidden SSID's
Date: Tue, 30 Jan 2007 01:08:29 -0600
Message-ID: <45BEEEED.9010702@lwfinger.net>
References: <45BACB71.2080107@lwfinger.net> <1169899689.25670.3.camel@localhost.localdomain> <1170019717.30318.0.camel@johannes.berg> <1170075611.2895.2.camel@localhost.localdomain> <20070130030911.GA6637@jm.kir.nu> <1170128208.3448.6.camel@localhost.localdomain> <45BECF04.3070904@lwfinger.net> <20070130050841.GC6637@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:61081 "EHLO
	mtiwmhc13.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964851AbXA3HIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 02:08:34 -0500
In-Reply-To: <20070130050841.GC6637@jm.kir.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> On Mon, Jan 29, 2007 at 10:52:20PM -0600, Larry Finger wrote:
> 
>> When an AP has a hidden SSID, ieee80211 fails, at least with wpa_supplicant,
>> which searches through the scan data looking for a particular ssid. Because
>> ieee80211 has substituted a false ssid, namely "<hidden>", wpa_supplicant
>> cannot authenticate. This behavior is fixed by adding a new argument to
>> ieee80211_translate_scan that contains the expected ssid.
> 
> Would this be replacing the SSID of all BSSes in scan results with the
> SSID for which the latest per-SSID scan was issued? If yes, this does
> not sound any better than the current behavior. The driver/802.11 code
> should not replace the SSID value with anything else than the value
> received from the AP.

Any AP with a hidden SSID will only respond to probe requests that specify its SSID, and will ignore
any other probes. In addition, the response will have an empty SSID field. These responses are the
only ones in which a substitution would occur. These are the same responses where the current code
sends back the "<hidden>" pseudo-SSID. My change would put the correct one there.

> In case of hidden SSIDs, the 802.11 implementation should maintain a
> list of BSSes found during the scan(s) and update the SSID (in most
> cases, by creating a new BSS entry) with the SSID from Probe Response
> frames. In other words, if the scan is done for a specific SSID (Probe
> Request includes that SSID), the AP that is using hidden SSIDs will
> likely include the SSID in Probe Response and data from that Probe
> Response can be used to fill in the missing pieces for the <BSSID,SSID>
> pair.
> 
> Generating false scan results by locally guessing what the SSID
> could be is just plain wrong. The scan results need to be based on real
> frames from the APs.

We aren't guessing. The response frame with the empty SSID field must have come from the AP with the
SSID we want. Filling in the expected value is just making it easier for the user-space tools.

Larry

