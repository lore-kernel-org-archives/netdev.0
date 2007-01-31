From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: Hidden SSID's
Date: Tue, 30 Jan 2007 20:35:18 -0600
Message-ID: <45C00066.80807@lwfinger.net>
References: <45BACB71.2080107@lwfinger.net> <1169899689.25670.3.camel@localhost.localdomain> <1170019717.30318.0.camel@johannes.berg> <1170075611.2895.2.camel@localhost.localdomain> <20070130030911.GA6637@jm.kir.nu> <1170128208.3448.6.camel@localhost.localdomain> <45BECF04.3070904@lwfinger.net> <20070130050841.GC6637@jm.kir.nu> <45BEEEED.9010702@lwfinger.net> <20070130225641.GH32304@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:59797 "EHLO
	mtiwmhc12.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752131AbXAaCfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 21:35:22 -0500
In-Reply-To: <20070130225641.GH32304@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> On Tue, Jan 30, 2007 at 01:08:29AM -0600, Larry Finger wrote:
> 
>> Any AP with a hidden SSID will only respond to probe requests that specify its SSID, and will ignore
>> any other probes. In addition, the response will have an empty SSID field. These responses are the
>> only ones in which a substitution would occur. These are the same responses where the current code
>> sends back the "<hidden>" pseudo-SSID. My change would put the correct one there.
> 
> Is the SSID from the probe response really used here? Your patch did not
> look like that.. The SSID from the last scan request command may not be
> the one that triggered the last scan (e.g., one could request a new scan
> without specifying an SSID).

If one does the equivalent of 'iwlist eth1 scan essid myssid', then a probe response with
NETWORK_EMPTY_ESSID set in the network flags will have 'myssid' returned in the SSID field of the
returned buffer. If the input command were 'iwlist eth1 scan', then an empty SSID would be returned
under the same circumstances. My code saves the SSID that is in the extra argument of the
SIOCSIWSCAN call, and uses that in the SIOCGIWSCAN call.
> 
>> We aren't guessing. The response frame with the empty SSID field must have come from the AP with the
>> SSID we want. Filling in the expected value is just making it easier for the user-space tools.
> 
> I don't see how the proposed patch would be using the correct SSID value
> in all cases. Especially cases where there are multiple APs using hidden
> SSIDs, but with different real SSID values and cases where multiple scan
> requests are being processed would be likely to leave windows open for
> reporting incorrect SSID.

I can think of one instance where the wrong value could be reported. That is if some other STA
probes a different hidden AP just when we have sent a probe request. For WPA this should not cause a
problem as wpa_supplicant will sort that out while authenticating.

What is the method that should be used to associated with a given hidden AP?

Larry




