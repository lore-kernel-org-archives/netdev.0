From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Tue, 17 Dec 2013 13:17:50 +1100
Message-ID: <CAGRGNgXHemM2FfnXgW5RbzhFT+9SfUfVkjdysK3+=_u3hWSacw@mail.gmail.com>
References: <1507831110.20131018194349@eikelenboom.it> <792757788.20131023142849@eikelenboom.it>
 <1819533168.20131211161710@eikelenboom.it> <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com>
 <1818324675.20131211175350@eikelenboom.it> <CAB=NE6Wf=T0bGLSYPDyb=-fMAVnGcbGkeaBiNrzwV-Lpxr6VZg@mail.gmail.com>
 <1342235583.20131211182804@eikelenboom.it> <CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com>
 <871324710.20131211191104@eikelenboom.it> <CAB=NE6XRnE0j9NMW0K1vKzEO9v70arSH4YXZjudqa0ZxiLB4AA@mail.gmail.com>
 <1937118387.20131216122200@eikelenboom.it> <52AEE60B.6030509@broadcom.com> <19210260274.20131216135644@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arend van Spriel <arend@broadcom.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Avinash Patil <avinashapatil@gmail.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <19210260274.20131216135644@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sander,

On Mon, Dec 16, 2013 at 11:56 PM, Sander Eikelenboom
<linux@eikelenboom.it> wrote:
>
> Monday, December 16, 2013, 12:37:47 PM, you wrote:
>
>> On 12/16/2013 12:22 PM, Sander Eikelenboom wrote:
>>>
>>> Wednesday, December 11, 2013, 7:38:50 PM, you wrote:
>>>
>>>> On Wed, Dec 11, 2013 at 7:11 PM, Sander Eikelenboom
>>>> <linux@eikelenboom.it> wrote:
>>>>>
>>>>> Wednesday, December 11, 2013, 6:53:07 PM, you wrote:
>>>>>
>>>>>> The best way to address all this is by automatic region awareness and
>>>>>> doing the right thing on devices, this however requires good
>>>>>> architecture / calibration data  / etc and all that needs to be
>>>>>> verified by the system integrators, and finally they need to be
>>>>>> certified. If you want to hack your firmware and software go at it,
>>>>>> just be aware there are reasons for things.
>>>>>
>>>>> Well the general problem seems to be "we don't trust the user" so we FORCE him to the lowest
>>>>> common denominator (without a way to overrule that) so he is forced to operate *well* within the law.
>>>
>>>> Its simply stupid to have the user be involved, period, the fact that
>>>> a user would be involved should only be for testing or helping
>>>> compliance for a busted device, development, research and obviously
>>>> hacking. Linux allows all these but by default a device with firmware
>>>> and a custom regdomain that will barf if you try to use a channel that
>>>> is not allowed is a restriction in firmware. Feel free to reverse
>>>> engineer that if you don't like it but it just won't be supported or
>>>> go upstream. Now, the common denominator is generally optimized for
>>>> best performance as well so you shouldn't have to do anything, and for
>>>> APs -- this is typically carefully crafted for a region, also highly
>>>> optimized.
>>>
>>>>>>>> It doesn't seem like you are getting your original requests getting
>>>>>>>> processed, so I don't think CRDA is passing it. Can you verify running
>>>>>>>> from CRDA code:
>>>>>>>
>>>>>>> They don't get processed unless i remove the return from the code as i indicated.
>>>>>>> If i remove that return it processes the request.
>>>>>>>
>>>>>>>> ./regdbdump /usr/lib/crda/regulatory.bin
>>>>>>>
>>>>>>> Although it's in a different location on Debian, /lib/crda/regulatory.bin
>>>>>>> the dump seems fine.
>>>>>
>>>>>> OK thanks. Can you send a patch of what exact change you made, it was
>>>>>> unclear from the paste you made.
>>>>>
>>>>>> diff -u file.c.orig file.c
>>>>>
>>>>> Well i just did a pull from wireless-next, to try Avinash Patil's patch.
>>>>> net/wireless/reg.c had already changed much so i couldn't apply his patch without.
>>>>>
>>>>> With his patch it sets the regulatory domain, although as now expected i still can not use channels 12 and 13 yet,
>>>>> probably due to those firmware restrictions.
>>>
>>>> Its unclear what results you got, and yeah if the device is restricted
>>>> then its just the fw telling the driver its channels and you can't use
>>>> them. That's it. You won't be able to override information then unless
>>>> you hack the firmware
>>>
>>> Ping ?
>>>
>>> Is there anymore information you need to *fix* the problem ?
>
>> Maybe you did not get the essence of the response from Luis: There is
>> *no* problem to be fixed.
>
> *sigh* ..
>
> Let's start from scratch then ...
>
>
> a) Isn't the point of the whole regulatory domain system that i can select (and restrict) the channels/frequencies my devices transmits on, so i can abide the law ?
> b) If so, does it set a regulatory domain from firmware  ?
> c) If so, should it let me *restrict* the available channels even more by setting the regulatory domain to the region in which de device is currently being used ?
> d) If so, why am i not  able to do so with my intel driver for a long time (for over a month now).
> # iw reg get
> country 00:
>         (2402 - 2472 @ 40), (6, 20)
>         (2457 - 2482 @ 40), (6, 20), PASSIVE-SCAN
>         (2474 - 2494 @ 20), (6, 20), NO-OFDM, PASSIVE-SCAN
>         (5170 - 5250 @ 160), (6, 20), PASSIVE-SCAN
>         (5250 - 5330 @ 160), (6, 20), DFS, PASSIVE-SCAN
>         (5490 - 5730 @ 160), (6, 20), DFS, PASSIVE-SCAN
> # iw reg set US
> # iw reg get
> country 00:
>         (2402 - 2472 @ 40), (6, 20)
>         (2457 - 2482 @ 40), (6, 20), PASSIVE-SCAN
>         (2474 - 2494 @ 20), (6, 20), NO-OFDM, PASSIVE-SCAN
>         (5170 - 5250 @ 160), (6, 20), PASSIVE-SCAN
>         (5250 - 5330 @ 160), (6, 20), DFS, PASSIVE-SCAN
>         (5490 - 5730 @ 160), (6, 20), DFS, PASSIVE-SCAN
>
> Dmesg only spits out:
> [  383.849977] cfg80211: Pending regulatory request, waiting for it to be processed...
>

As has been explained previously, this indicates that, somehow, CRDA
is not answering the kernel's requests as it should. Looking at the
dmesg you posted before, we have:

[    3.862108] cfg80211: Calling CRDA to update world regulatory domain

which never gets a reply.

Are you using your distro's official CRDA package or have you compiled
your own? It might not be installed properly as it looks like it's not
responding to the kernel's call to update the world regulatory domain.
There's more to installing CRDA than just sticking the executable and
database in the right places.

On my system here, I have:

[   16.981114] cfg80211: Calling CRDA to update world regulatory domain
...
[   17.300582] cfg80211: World regulatory domain updated:
[   17.300592] cfg80211:   (start_freq - end_freq @ bandwidth),
(max_antenna_gain, max_eirp)
[   17.300594] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm)
[   17.300597] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm)
[   17.300598] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz),
(300 mBi, 2000 mBm)
[   17.300600] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm)
[   17.300602] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm)

Your dmesg doesn't have the response listed, therefore CRDA is not
responding to the kernel's requests. The kernel will not make
additional requests until the previous one is answered.

> e) So why doesn't this whole regulatory mumbojumbo and the Linux implementation in particular let me abide the law ?!? Wasn't that it's *sole* point of existence ?

It _is_ doing this.

The world regulatory domain is the intersection of all the regulatory
domains we know of. This is the _most_ restricted version which
_ensures_ that you're obeying the law _everywhere_.

> f) Why doesn't seem anyone to be seriously looking at it (for over a month now, while everyone from wireless/80211 to intel driver maintainers were CC'ed) ?

Because there is no bug in the kernel, the bug is in your system's setup.

> g) Saying it has got to do with reg db's not being found or all kinds of other arguments while
>    the report clearly stated the way it can be circumvented by 2 simple patches that don't seem to involve any changes to
>    how it finds the reg db (apart from that i tested that a few times on request and indicated it didn't matter)
>    in current 3.13 code (and 3.12 and perhaps even earlier) (case 1)
>    or
>    with current wireless-next pulled (which has quite some changes to reg.c but none fixes this) onto 3.13 (case 2)
>    Neither of these patches might be correct codewise, but at least it let's me set the regulatory domain, and the current state the code is in is neither correct.

These patches _break_ the functionality of the kernel, not fix it.

They allow the kernel to issue requests before the previous one is
answered. This is a bug. There are good reasons why this is not
allowed.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
