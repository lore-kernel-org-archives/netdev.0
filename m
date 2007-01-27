From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: Hidden SSID's
Date: Sat, 27 Jan 2007 09:29:24 -0600
Message-ID: <45BB6FD4.4010907@lwfinger.net>
References: <45BACB71.2080107@lwfinger.net> <1169899689.25670.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:62644 "EHLO
	mtiwmhc12.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751859AbXA0P3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jan 2007 10:29:32 -0500
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

The situation might not be too bad. The routine in ieee80211 has two direct callers, ipw2100 and
ipw2200, and is called through ieee80211softmac by bcm43xx and zd1211rw. I'll contact the
maintainers and see if we can reach an agreement regarding removal of the bad info.

Thanks for your response.

Larry
