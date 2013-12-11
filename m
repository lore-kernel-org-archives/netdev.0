From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Wed, 11 Dec 2013 18:53:07 +0100
Message-ID: <CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com>
References: <1507831110.20131018194349@eikelenboom.it> <792757788.20131023142849@eikelenboom.it>
 <1819533168.20131211161710@eikelenboom.it> <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com>
 <1818324675.20131211175350@eikelenboom.it> <CAB=NE6Wf=T0bGLSYPDyb=-fMAVnGcbGkeaBiNrzwV-Lpxr6VZg@mail.gmail.com>
 <1342235583.20131211182804@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34453 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803Ab3LKRxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 12:53:32 -0500
In-Reply-To: <1342235583.20131211182804@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 6:28 PM, Sander Eikelenboom
<linux@eikelenboom.it> wrote:
> Wednesday, December 11, 2013, 6:14:16 PM, you wrote:
>> Yeap, that's the case for Intel Atheros, and I think nowadays new
>> broadcom upstream drivers too. Users should not have to be involved on
>> setting the regulatory domain, everything should just work
>> automatically.
>
> Erhmm yes that works, under the assumption that the device is not leaving the country it was programmed for at the factory.

Moving out of a region that you purchased a device is called to "world
roam". Believe it or not some devices are designed with the intent you
do not take it out of a country. The Playstation comes to mind as an
example but I believe some Apple tablets are also in the same
situation. Some devices like mobile phones obviously need to support
world roaming and they do, what they do then is build architecture to
support a base set and then rely on your APs around to see the country
IE to determine region. Some other devices rely on cellular base
station information, but that is allowed only in a few countries right
now and in the US at least this requires some sort of special review
from FCC on the design. We support all this in the Linux kernel today,
its up to system integrators to do things and certify things properly.

> (Or you like to be limited in your abilities, channel 12 and 13 are legal here)
> That there is a restriction on boot or on first use, i can understand. Crippling a device for it's life time though.

The best way to address all this is by automatic region awareness and
doing the right thing on devices, this however requires good
architecture / calibration data  / etc and all that needs to be
verified by the system integrators, and finally they need to be
certified. If you want to hack your firmware and software go at it,
just be aware there are reasons for things.

>> It doesn't seem like you are getting your original requests getting
>> processed, so I don't think CRDA is passing it. Can you verify running
>> from CRDA code:
>
> They don't get processed unless i remove the return from the code as i indicated.
> If i remove that return it processes the request.
>
>> ./regdbdump /usr/lib/crda/regulatory.bin
>
> Although it's in a different location on Debian, /lib/crda/regulatory.bin
> the dump seems fine.

OK thanks. Can you send a patch of what exact change you made, it was
unclear from the paste you made.

diff -u file.c.orig file.c

  Luis
