From: Dan Williams <dcbw@redhat.com>
Subject: Re: Scanning in ieee80211 softmac layer and setting essid (newbie)
Date: Tue, 09 May 2006 11:26:53 -0400
Message-ID: <1147188413.4979.3.camel@localhost.localdomain>
References: <d0383f90605090638u3ca7a5c0je1a4ce8bc3dc696e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:5335 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932519AbWEIP2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 11:28:37 -0400
To: Ian Brown <ianbrn@gmail.com>
In-Reply-To: <d0383f90605090638u3ca7a5c0je1a4ce8bc3dc696e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-05-09 at 16:38 +0300, Ian Brown wrote:
> Hello,
> I see that setting the essid of a wireless card
> (by iwconfig eth1 essid homenet)
> triggers scanning;
> My question is : why is this scanning needed when set essid is called?
> and why is the repeatition?

Because the wireless card needs to know information about the access
point before it can associate, like channel, BSSID, supported rates,
etc.  None of these things are indicated by the SSID you've just set on
the card. Normally, when you set an SSID and the card knows nothing
about that SSID, the card will scan all channels looking for access
points that happen to match the SSID you've just set.  It can then get
all the necessary information that it needs to connect to the access
point, but only _after_ it's scanned and found one with that SSID.

If the card does background scanning and keeps a list of access points
on its own, that makes things a little faster.  But the scan is still
necessary in many instances.

Dan


