From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Mon, 16 Dec 2013 13:56:44 +0100
Message-ID: <19210260274.20131216135644@eikelenboom.it>
References: <1507831110.20131018194349@eikelenboom.it> <792757788.20131023142849@eikelenboom.it> <1819533168.20131211161710@eikelenboom.it> <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com> <1818324675.20131211175350@eikelenboom.it> <CAB=NE6Wf=T0bGLSYPDyb=-fMAVnGcbGkeaBiNrzwV-Lpxr6VZg@mail.gmail.com> <1342235583.20131211182804@eikelenboom.it> <CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com> <871324710.20131211191104@eikelenboom.it> <CAB=NE6XRnE0j9NMW0K1vKzEO9v70arSH4YXZjudqa0ZxiLB4AA@mail.gmail.com> <1937118387.20131216122200@eikelenboom.it> <52AEE60B.6030509@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Avinash Patil <avinashapatil@gmail.com>
To: Arend van Spriel <arend@broadcom.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52AEE60B.6030509@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Monday, December 16, 2013, 12:37:47 PM, you wrote:

> On 12/16/2013 12:22 PM, Sander Eikelenboom wrote:
>> 
>> Wednesday, December 11, 2013, 7:38:50 PM, you wrote:
>> 
>>> On Wed, Dec 11, 2013 at 7:11 PM, Sander Eikelenboom
>>> <linux@eikelenboom.it> wrote:
>>>>
>>>> Wednesday, December 11, 2013, 6:53:07 PM, you wrote:
>>>>
>>>>> The best way to address all this is by automatic region awareness and
>>>>> doing the right thing on devices, this however requires good
>>>>> architecture / calibration data  / etc and all that needs to be
>>>>> verified by the system integrators, and finally they need to be
>>>>> certified. If you want to hack your firmware and software go at it,
>>>>> just be aware there are reasons for things.
>>>>
>>>> Well the general problem seems to be "we don't trust the user" so we FORCE him to the lowest
>>>> common denominator (without a way to overrule that) so he is forced to operate *well* within the law.
>> 
>>> Its simply stupid to have the user be involved, period, the fact that
>>> a user would be involved should only be for testing or helping
>>> compliance for a busted device, development, research and obviously
>>> hacking. Linux allows all these but by default a device with firmware
>>> and a custom regdomain that will barf if you try to use a channel that
>>> is not allowed is a restriction in firmware. Feel free to reverse
>>> engineer that if you don't like it but it just won't be supported or
>>> go upstream. Now, the common denominator is generally optimized for
>>> best performance as well so you shouldn't have to do anything, and for
>>> APs -- this is typically carefully crafted for a region, also highly
>>> optimized.
>> 
>>>>>>> It doesn't seem like you are getting your original requests getting
>>>>>>> processed, so I don't think CRDA is passing it. Can you verify running
>>>>>>> from CRDA code:
>>>>>>
>>>>>> They don't get processed unless i remove the return from the code as i indicated.
>>>>>> If i remove that return it processes the request.
>>>>>>
>>>>>>> ./regdbdump /usr/lib/crda/regulatory.bin
>>>>>>
>>>>>> Although it's in a different location on Debian, /lib/crda/regulatory.bin
>>>>>> the dump seems fine.
>>>>
>>>>> OK thanks. Can you send a patch of what exact change you made, it was
>>>>> unclear from the paste you made.
>>>>
>>>>> diff -u file.c.orig file.c
>>>>
>>>> Well i just did a pull from wireless-next, to try Avinash Patil's patch.
>>>> net/wireless/reg.c had already changed much so i couldn't apply his patch without.
>>>>
>>>> With his patch it sets the regulatory domain, although as now expected i still can not use channels 12 and 13 yet,
>>>> probably due to those firmware restrictions.
>> 
>>> Its unclear what results you got, and yeah if the device is restricted
>>> then its just the fw telling the driver its channels and you can't use
>>> them. That's it. You won't be able to override information then unless
>>> you hack the firmware
>> 
>> Ping ?
>> 
>> Is there anymore information you need to *fix* the problem ?

> Maybe you did not get the essence of the response from Luis: There is
> *no* problem to be fixed.

*sigh* ..

Let's start from scratch then ...


a) Isn't the point of the whole regulatory domain system that i can select (and restrict) the channels/frequencies my devices transmits on, so i can abide the law ?
b) If so, does it set a regulatory domain from firmware  ?
c) If so, should it let me *restrict* the available channels even more by setting the regulatory domain to the region in which de device is currently being used ?
d) If so, why am i not  able to do so with my intel driver for a long time (for over a month now).
# iw reg get
country 00:
        (2402 - 2472 @ 40), (6, 20)
        (2457 - 2482 @ 40), (6, 20), PASSIVE-SCAN
        (2474 - 2494 @ 20), (6, 20), NO-OFDM, PASSIVE-SCAN
        (5170 - 5250 @ 160), (6, 20), PASSIVE-SCAN
        (5250 - 5330 @ 160), (6, 20), DFS, PASSIVE-SCAN
        (5490 - 5730 @ 160), (6, 20), DFS, PASSIVE-SCAN
# iw reg set US
# iw reg get
country 00:
        (2402 - 2472 @ 40), (6, 20)
        (2457 - 2482 @ 40), (6, 20), PASSIVE-SCAN
        (2474 - 2494 @ 20), (6, 20), NO-OFDM, PASSIVE-SCAN
        (5170 - 5250 @ 160), (6, 20), PASSIVE-SCAN
        (5250 - 5330 @ 160), (6, 20), DFS, PASSIVE-SCAN
        (5490 - 5730 @ 160), (6, 20), DFS, PASSIVE-SCAN

Dmesg only spits out:
[  383.849977] cfg80211: Pending regulatory request, waiting for it to be processed...

e) So why doesn't this whole regulatory mumbojumbo and the Linux implementation in particular let me abide the law ?!? Wasn't that it's *sole* point of existence ?
f) Why doesn't seem anyone to be seriously looking at it (for over a month now, while everyone from wireless/80211 to intel driver maintainers were CC'ed) ?
g) Saying it has got to do with reg db's not being found or all kinds of other arguments while
   the report clearly stated the way it can be circumvented by 2 simple patches that don't seem to involve any changes to
   how it finds the reg db (apart from that i tested that a few times on request and indicated it didn't matter)
   in current 3.13 code (and 3.12 and perhaps even earlier) (case 1)
   or
   with current wireless-next pulled (which has quite some changes to reg.c but none fixes this) onto 3.13 (case 2)
   Neither of these patches might be correct codewise, but at least it let's me set the regulatory domain, and the current state the code is in is neither correct.
h) Added Linus to the CC, you never know if that automagically kicks things in gear ... (hopefully not in reverse :-p)

Case 1 - patch that makes it possible to set the regulatory domain without silently ignoring it - applies to 3.13-rc4

diff --git a/net/wireless/reg.c b/net/wireless/reg.c

index 7da67fd..e8ab82e 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1579,7 +1579,7 @@ static void reg_process_pending_hints(void)
        /* When last_request->processed becomes true this will be rescheduled */
        if (lr && !lr->processed) {
                REG_DBG_PRINT("Pending regulatory request, waiting for it to be processed...\n");
-               return;
+               /* return; */
        }

        spin_lock(&reg_requests_lock);





Case 2 - RFC patch by Avinash Patil that makes it possible to set the regulatory domain without silently ignoring it - applies to 3.13-rc4 + wireless-next pulled onto it

---------- Forwarded message ----------
From: "Avinash Patil" <patila@marvell.com>
Date: Dec 6, 2013 8:31 PM
Subject: [RFC] cfg80211: set regulatory request processed for initiator core
To: <johannes@sipsolutions.net>, <linux-wireless@vger.kernel.org>
Cc:

During cfg80211 init, cfg80211 initializes regulatory to set to
world domain. Here we dont set last request processed flag.
This results into further request set to pending indefinitely.

This patch fixes this by setting last request to processed.

Signed-off-by: Avinash Patil <patila@marvell.com>
---
 net/wireless/reg.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index ec54e1a..70a8f0a 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1670,6 +1670,8 @@ static void reg_process_hint(struct
regulatory_request *reg_request)
        switch (reg_request->initiator) {
        case NL80211_REGDOM_SET_BY_CORE:
                reg_process_hint_core(reg_request);
+               nl80211_send_reg_change_event(reg_request);
+               reg_set_request_processed();
                return;
        case NL80211_REGDOM_SET_BY_USER:
                treatment = reg_process_hint_user(reg_request);
--
1.7.3.4



> Gr. AvS
