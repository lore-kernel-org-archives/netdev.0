From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC, 1/2] ethtool: Implement private flags interface for ethtool application.
Date: Sat, 3 Sep 2011 03:39:39 +0200
Message-ID: <CAHXqBFLqVrgo=Gu0cqM=ZCav0yHRxCiC7LQLsQPgPm=4UHoMNg@mail.gmail.com>
References: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
 <20110902.165524.1076389492712310664.davem@davemloft.net> <EDC0E76513226749BFBC9C3FB031318F0173FF8607@orsmsx508.amr.corp.intel.com>
 <CAHXqBFKU2m6s1fQzZpJRvvR2HatJpXjWXv84=ZYD5E6OPFfUmQ@mail.gmail.com>
 <CAHXqBF+9iP6tOmtiaXopGvLyBZvpXmLz05aHj1MrQ2RnAiGGLA@mail.gmail.com> <1314999272.3419.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36912 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377Ab1ICBj7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 21:39:59 -0400
Received: by iabu26 with SMTP id u26so3606911iab.19
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2011 18:39:59 -0700 (PDT)
In-Reply-To: <1314999272.3419.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2 wrze=B6nia 2011 23:34 u=BFytkownik Ben Hutchings
<bhutchings@solarflare.com> napisa=B3:
> On Fri, 2011-09-02 at 23:22 +0200, Micha=B3 Miros=B3aw wrote:
>> W dniu 2 wrze=B6nia 2011 23:17 u=BFytkownik Micha=B3 Miros=B3aw
>> <mirqus@gmail.com> napisa=B3:
>> > 2011/9/2 Wyborny, Carolyn <carolyn.wyborny@intel.com>:
>> >>>-----Original Message-----
>> >>>From: David Miller [mailto:davem@davemloft.net]
>> >>>Sent: Friday, September 02, 2011 1:55 PM
>> >>>To: Wyborny, Carolyn
>> >>>Cc: bhutchings@solarflare.com; netdev@vger.kernel.org
>> >>>Subject: Re: [RFC, 1/2] ethtool: Implement private flags interfac=
e for
>> >>>ethtool application.
>> >>>
>> >>>From: Carolyn Wyborny <carolyn.wyborny@intel.com>
>> >>>Date: Fri, =A02 Sep 2011 13:50:30 -0700
>> >>>
>> >>>> This patch completes the user space implementation of the priva=
te
>> >>>> flags inteface in ethtool. Using -b/-B options.
>> >>>>
>> >>>> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
>> >>>
>> >>>The only use case you show here is something generic which other
>> >>>chips have, Energy Efficient Ethernet.
>> >>>
>> >>>Making an attribute private which is present widely amonst variou=
s
>> >>>networking chips makes no sense at all.
>> >>>
>> >>>It deserved a generic ethtool flag.
>> >>
>> >> Fair enough on this particular feature, but does that negate the =
implementation suggestion altogether? =A0I can send an updated feature =
implementation for the use case using DMA Coalescing if that will help.
>> > I would rather see this as an extension to ETHTOOL_[GS]FEATURES. I=
ts
>> > semantics allow easy expanding to handle device-private flags with=
out
>> > changing anything on userspace side.
>>
>> BTW, After pending Intel drivers get converted to ndo_set_features a=
nd
>> netdev->features get extended to 64 bits, it would also be possible =
to
>> use some of the unused bits there for device/driver-private flags
>> almost "for free".
> I don't really like the idea of mixing common feature flags with
> driver-specific flags. =A0It's likely to lead to confusion if you mix
> devices with different drivers in a bridge or a bond.

I assume that device-specific flags won't ever be included in
vlan_features not be transferred in other ways to bridge or bonding.
If this holds, then it doesn't really matter how the flags are stored
and if they are included in features. I'll make a PoC implementation
to show the idea only after the feature cleanup is done, as otherwise
I would have yet another idea hanging in the queue.

Rough sketch is that there would be some number of bits in features
left after all global ones that drivers would present to userspace by
appending feature names to the string set returned for
ETH_SS_FEATURES. Those names would need to have common prefix like
'priv-' or maybe driver name prepended, and be documented as not
something that shoud be regarded as stable.

Best Regards,
Micha=B3 Miros=B3aw
