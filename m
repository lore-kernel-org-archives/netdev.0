From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: Hidden SSID's
Date: Tue, 30 Jan 2007 14:56:41 -0800
Message-ID: <20070130225641.GH32304@instant802.com>
References: <45BACB71.2080107@lwfinger.net> <1169899689.25670.3.camel@localhost.localdomain> <1170019717.30318.0.camel@johannes.berg> <1170075611.2895.2.camel@localhost.localdomain> <20070130030911.GA6637@jm.kir.nu> <1170128208.3448.6.camel@localhost.localdomain> <45BECF04.3070904@lwfinger.net> <20070130050841.GC6637@jm.kir.nu> <45BEEEED.9010702@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Larry Finger <larry.finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-68.dex002.intermedia.net ([64.78.20.34]:24774 "EHLO
	DHOST002-68.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751943AbXA3W62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 17:58:28 -0500
Content-Disposition: inline
In-Reply-To: <45BEEEED.9010702@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 30, 2007 at 01:08:29AM -0600, Larry Finger wrote:

> Any AP with a hidden SSID will only respond to probe requests that specify its SSID, and will ignore
> any other probes. In addition, the response will have an empty SSID field. These responses are the
> only ones in which a substitution would occur. These are the same responses where the current code
> sends back the "<hidden>" pseudo-SSID. My change would put the correct one there.

Is the SSID from the probe response really used here? Your patch did not
look like that.. The SSID from the last scan request command may not be
the one that triggered the last scan (e.g., one could request a new scan
without specifying an SSID).

> We aren't guessing. The response frame with the empty SSID field must have come from the AP with the
> SSID we want. Filling in the expected value is just making it easier for the user-space tools.

I don't see how the proposed patch would be using the correct SSID value
in all cases. Especially cases where there are multiple APs using hidden
SSIDs, but with different real SSID values and cases where multiple scan
requests are being processed would be likely to leave windows open for
reporting incorrect SSID.

-- 
Jouni Malinen                                            PGP id EFC895FA
