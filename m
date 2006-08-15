From: Michael Buesch <mb@bu3sch.de>
Subject: Re: proposal for new wireless configuration API
Date: Tue, 15 Aug 2006 21:35:53 +0200
Message-ID: <200608152135.54238.mb@bu3sch.de>
References: <C86180A8C204554D8A3323D8F6B0A29F0165AE04@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jean Tourrilhes" <jt@hpl.hp.com>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"Dan Williams" <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:53922
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030474AbWHOTgw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 15:36:52 -0400
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165AE04@dhost002-46.dex002.intermedia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 15 August 2006 21:27, Simon Barber wrote:
> A further complication happens in Japan with 802.11j, and now in the USA
> too - with 802.11y in the 3.65Ghz band - here there are some new channel
> widths that are possible. Normally 802.11 is 20 or 22Mhz wide (20Mhz for
> OFDM modulations - 11a/g, 22 for 11b). In Japan's 4.9Ghz band you can
> run the OFDM at half rate, giving a 10Mhz wide channel, or at quarter
> rate, giving a 5Mhz wide channel. Hence same frequency, different
> channel spec. Using a channel number is the way to go. If we need
> something to convert between the 2 it should probably be a library in
> user space (in hostapd or wpa_supplicant) - hostapd does have this
> today.
>
> It might be nice if other applications could access this data too - but
> I don't think it needs to be inside the kernel.

We need this conversion function, as most devices tune to frequencies,
not channels. So when a driver is instructed to tune to channel 2,
it must call back into the 80211 stack to ask for the frequency (based
on the current PHYMODE and the other parameters you mentioned above).
That call should IMO not result in a call to userspace. Userspace
should instead set flags _before_ in the stack and the conversion
callback would act on these flags.
That way userspace only has to tell the kernel once which frequency-band,
half, quater freq, or whatever it wants. The actual conversion
from channel number to freq (or the other way around) is trivial after
that, as it's only a few ifs and elses based on some cheap flags.

-- 
Greetings Michael.
