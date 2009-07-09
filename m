From: Frans Pop <elendil@planet.nl>
Subject: Re: [regression] ath5k: Overrides regulatory domain set for cfg80211
Date: Thu, 9 Jul 2009 03:11:39 +0200
Message-ID: <200907090311.40205.elendil@planet.nl>
References: <200907082340.07787.elendil@planet.nl> <43e72e890907081508n6fa5781an1dcbda078efc5379@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml107.kpnxchange.com ([195.121.3.11]:60737 "EHLO
	CPSMTPM-EML107.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756166AbZGIBLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 21:11:42 -0400
In-Reply-To: <43e72e890907081508n6fa5781an1dcbda078efc5379@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the quick reply and elaborate explanation Luis.

On Thursday 09 July 2009, Luis R. Rodriguez wrote:
> It looks as if, but you a few things you should be aware of.

I was aware that things are changing in this area, but as I'm running 
Debian stable (Lenny) on this box I don't yet have a "new" userland and 
would like to see things continue to work correctly.
For Debian iw is available in testing/unstable, but not in stable.

It also means that I don't have the CRDA agent running, so IIUC currently 
the 'calls to CRDA' don't actually do anything for me. From that 
perspective I guess you could say nothing actually breaks.

> First, its not that anything is being ignored, user input is always
> welcomed to help compliance you are just using a wrong ISO-3166
> alpha2.
>
> EU is not a country and as such is only left on older kernels with
> CONFIG_WIRELESS_OLD_REGULATORY  enabled. So "EU" is deprecated for non
> CONFIG_WIRELESS_OLD_REGULATORY based kernels now.

I *do* have CONFIG_WIRELESS_OLD_REGULATORY set for exactly the reason that 
I know I don't yet have the new userland.

And if I change the country code to NL, I still get the same problem:
cfg80211: Using static regulatory domain info
cfg80211: Regulatory domain: US
        (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
        (2402000 KHz - 2472000 KHz @ 40000 KHz), (600 mBi, 2700 mBm)
        (5170000 KHz - 5190000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5190000 KHz - 5210000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5210000 KHz - 5230000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5230000 KHz - 5330000 KHz @ 40000 KHz), (600 mBi, 2300 mBm)
        (5735000 KHz - 5835000 KHz @ 40000 KHz), (600 mBi, 3000 mBm)
  [Weird, when I specified EU I at least got the EU domain here.]
  [Now I specify NL and it gives me US; how's that an improvement?]
cfg80211: Calling CRDA for country: NL
  [no agent, so this does not actually change anything]
ath5k 0000:02:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
ath5k 0000:02:00.0: registered as 'phy0'
ath: EEPROM regdomain: 0x30
ath: EEPROM indicates we should expect a direct regpair map
ath: Country alpha2 being used: AM
ath: Regpair used: 0x30
phy0: Selected rate control algorithm 'minstrel'
ath5k phy0: Atheros AR5213A chip found (MAC: 0x59, PHY: 0x43)
ath5k phy0: RF2112B 2GHz radio found (0x46)
cfg80211: Calling CRDA for country: AM
  [no agent, so this does not actually change anything]

> For further information please also read
> Documentation/feature-removal-schedule.txt. Please use a valid
> ISO-3166 alpha2 country code, I also advise to abandon the usage of
> the ieee80211_regdom module parameter which we do eventually intend on
> deprecating and if you know anyone using that please suggest the same.

As mentioned above I do not currently have the option of abandoning it.
Please continue to provide full backwards compatibility with "old" 
userland until all major distros have iw and crda in their stable 
releases.

> Eventually, as you will read from the feature-removal schedule, we
> intend on getting the Linux desktop to provide automatic hints of the
> user's location through things like GeoClue. Reason for removing the
> module parameter is its not the proper way to pass information to the
> kernel, we now have a netlink interface for this exact purpose. Until
> the desktop catches up we'll keep the ieee80211_regdom module
> parameter, but the proper new way to set your regulatory domain as a
> user is through iw [1] which does use netlink. Some distributions
> (like Fedora) automatically set your country based on the timezone
> information. So in the end you should not have to do this at all as a
> user.

Excellent for the future, but not yet an option for me.

> Another thing you should note is that if a driver has a regulatory
> domain hint then the driver regulatory domain is always trusted, users
> can *further* help compliance by selecting their country. What this 
> means since Atheros drivers do have EEPROM reading for the regulatory
> domain that will be used first, thus enabling only channels allowed by
> the programmed EEPROM.

That seems particularly bad in my case. For some weird reason this Trust 
PCMCIA card seems to have AM in its EEPROM, which is Armenia...
The card was bought in the Netherlands (NL), which is also where I live.

I have no idea what the regulations are in Armenia, but it seems damned 
silly to me to be restricted in this way just because of random hardware 
manufacturer's settings. I thought in the Linux world we'd long accepted 
that hardware manufacturers can't be trusted to get such things right.
Even ignoring the completely valid case of someone buying hardware in one 
country and then moving to another one.

I can to some extend understand respecting hardware settings for APs, but 
for a wireless NIC it seems a useless limitation. And I also suspect that 
manufacturers of (cheap) NICs are much more likely to get the hardware 
setting wrong (basically by not caring).

Cheers,
FJP
