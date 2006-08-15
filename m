From: Dan Williams <dcbw@redhat.com>
Subject: Re: proposal for new wireless configuration API
Date: Tue, 15 Aug 2006 16:06:07 -0400
Message-ID: <1155672367.19284.16.camel@localhost.localdomain>
References: <C86180A8C204554D8A3323D8F6B0A29F0165AE04@dhost002-46.dex002.intermedia.net>
	 <200608152135.54238.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Simon Barber <simon@devicescape.com>, netdev@vger.kernel.org,
	Jean Tourrilhes <jt@hpl.hp.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33476 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932785AbWHOUG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 16:06:59 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200608152135.54238.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 21:35 +0200, Michael Buesch wrote:
> On Tuesday 15 August 2006 21:27, Simon Barber wrote:
> > A further complication happens in Japan with 802.11j, and now in the USA
> > too - with 802.11y in the 3.65Ghz band - here there are some new channel
> > widths that are possible. Normally 802.11 is 20 or 22Mhz wide (20Mhz for
> > OFDM modulations - 11a/g, 22 for 11b). In Japan's 4.9Ghz band you can
> > run the OFDM at half rate, giving a 10Mhz wide channel, or at quarter
> > rate, giving a 5Mhz wide channel. Hence same frequency, different
> > channel spec. Using a channel number is the way to go. If we need
> > something to convert between the 2 it should probably be a library in
> > user space (in hostapd or wpa_supplicant) - hostapd does have this
> > today.
> >
> > It might be nice if other applications could access this data too - but
> > I don't think it needs to be inside the kernel.
> 
> We need this conversion function, as most devices tune to frequencies,
> not channels. So when a driver is instructed to tune to channel 2,
> it must call back into the 80211 stack to ask for the frequency (based
> on the current PHYMODE and the other parameters you mentioned above).
> That call should IMO not result in a call to userspace. Userspace
> should instead set flags _before_ in the stack and the conversion
> callback would act on these flags.
> That way userspace only has to tell the kernel once which frequency-band,
> half, quater freq, or whatever it wants. The actual conversion
> from channel number to freq (or the other way around) is trivial after
> that, as it's only a few ifs and elses based on some cheap flags.

As long as there's a way for userspace to convert channel <-> frequency
and back using the _same_ values as the driver is using, that's all I
care about.  I just don't want to have each userspace program have its
own library of channel/frequency mappings simply because not enough
information was exposed through the d80211 stack's API.

Dan


