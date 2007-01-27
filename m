From: Dan Williams <dcbw@redhat.com>
Subject: Re: Hidden SSID's
Date: Sat, 27 Jan 2007 07:08:09 -0500
Message-ID: <1169899689.25670.3.camel@localhost.localdomain>
References: <45BACB71.2080107@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690AbXA0MFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Jan 2007 07:05:37 -0500
In-Reply-To: <45BACB71.2080107@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-01-26 at 21:48 -0600, Larry Finger wrote:
> Is there a convention regarding the information that a wireless MAC layer should provide when
> reporting scan data from an AP with a hidden SSID?
> 
> In ieee80211, the software inserts the string "<hidden>" for such an AP, which seems to give
> wpa_supplicant fits because it rejects the SSID before even looking at the encryption data. Is this
> the normal convention?

No.  It's wrong.  It is not normal convention.  The one and only
_correct_ way of reporting a hidden SSID is to not report the SSID at
all.  The only item that needs to be reported with WEXT is the BSSID,
and the client app assumes that if the SSID is not received for a given
scan result, that the driver doesn't have an SSID for that BSSID.

I really, really don't know why ieee80211 uses <hidden>, but it's a pain
in the ass and should NOT be done for d80211.  I don't know if we can
ever remove it from ieee80211 though for backwards compat reasons.

Dan

> Thanks,
> 
> Larry
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

