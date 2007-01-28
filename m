From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: Hidden SSID's
Date: Sun, 28 Jan 2007 16:18:01 -0600
Message-ID: <45BD2119.2000209@lwfinger.net>
References: <45BACB71.2080107@lwfinger.net> <1169899689.25670.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Paul Marks <pmarks@purdue.edu>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:45019 "EHLO
	mtiwmhc12.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932498AbXA1WSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 17:18:06 -0500
In-Reply-To: <1169899689.25670.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> On Fri, 2007-01-26 at 21:48 -0600, Larry Finger wrote:
>> Is there a convention regarding the information that a wireless MAC layer should provide when
>> reporting scan data from an AP with a hidden SSID?
>>
>> In ieee80211, the software inserts the string "<hidden>" for such an AP, which seems to give
>> wpa_supplicant fits because it rejects the SSID before even looking at the encryption data. Is this
>> the normal convention?
> 
> No.  It's wrong.  It is not normal convention.  The one and only
> _correct_ way of reporting a hidden SSID is to not report the SSID at
> all.  The only item that needs to be reported with WEXT is the BSSID,
> and the client app assumes that if the SSID is not received for a given
> scan result, that the driver doesn't have an SSID for that BSSID.
> 
> I really, really don't know why ieee80211 uses <hidden>, but it's a pain
> in the ass and should NOT be done for d80211.  I don't know if we can
> ever remove it from ieee80211 though for backwards compat reasons.

Is there something funny about Cisco APs with hidden SSID? I made a patch for ieee80211 and softmac
that works on my AP when its SSID is hidden. It also works for Paul Marks on his personal AP, but
fails for the Cisco units at Purdue. His interface is a 4311 and there may be a signal strength
issue, but we are not sure.

My patch fixes ieee80211 without breaking the previous behavior.

Larry
