From: Arend van Spriel <arend@broadcom.com>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Thu, 9 Oct 2014 09:52:48 +0200
Message-ID: <54363ED0.605@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <2326963.udog5tteBt@eisbaer> <542A8092.9090602@broadcom.com> <1527190.sqFmD6XRNJ@eisbaer>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	Seth Forshee <seth.forshee@canonical.com>,
	<brcm80211-dev-list@broadcom.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:59822 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbaJIHww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 03:52:52 -0400
In-Reply-To: <1527190.sqFmD6XRNJ@eisbaer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/14 00:19, Maximilian Engelhardt wrote:
> On Tuesday 30 September 2014 12:06:10 Arend van Spriel wrote:
>> On 09/29/14 21:40, Maximilian Engelhardt wrote:
>>> On Monday 29 September 2014 15:44:03 Arend van Spriel wrote:
>>>> On 09/26/14 17:20, Michael Tokarev wrote:
>>>>> I can send it your way, -- guess it will be quite a bit costly,
>>>>> but I don't have any use for it anyway (short of throwing it
>>>>> away), and since I already spent significantly more money due
>>>>> to all this (whole thinkpad plus ssds and several wifi adaptors),
>>>>> this additional cost is just a small noize.  But since that's
>>>>> 2nd card in a row, maybe there's something else in there, the
>>>>> prob is not in the card?
>>>>
>>>> Could be. Maybe some BIOS issue. Can you make some hi-res pictures of
>>>> the card and email them to me? If it is identical to what I already have
>>>> over here there is not much sense in sending it.
>>>>
>>>> Regards,
>>>> Arend
>>>
>>> Hi Arend,
>>>
>>> I just saw this thread on linux-wireless and wanted to answer as it might
>>> be of interest to you.
>>>
>>> I also own a BCM4313 wireless network card. About a year ago I reported
>>> some problems with reception strength which were then fixed after some
>>> time, debugging and testing passed. At that time I also did some
>>> throughput testing, but only had a 802.11g access-point to test. The
>>> results were not ideal, but also not too bad. So at that time I thought
>>> the issues were all more or less fixed and mostly fine. I also don't use
>>> wireless very much, so as long as things do work somehow acceptable I
>>> probably don't notice any problems immediately. So it comes that only
>>> about some month ago I noticed that the throughput I measured with my 11g
>>> access-point (about half the rate than with an atheros card on the same
>>> ap) is about the same on a 11n access-point where it should be much
>>> faster. I didn't experience any stalls, but that may also be that I
>>> didn't use the card enough to really notice them.
>>>
>>> I always wanted to report a bug because of the low throughout, but never
>>> got to it because of lack of time. I didn't want to provide a report
>>> saying just it doesn't work or it's slow without any data about it and a
>>> description how to reproduce it, as I think without this information a
>>> bug report is mostly useless.
>>>
>>> I also had a look at the kernel changelog of the brcmsm driver and notices
>>> there was little to no activity lately. Because of this I also wasn't sure
>>> if there is still someone interesting in fixing bugs for this device.
>>>
>>> As I was annoyed by the bad support for this card I decided it would be
>>> more easy and much less time consuming to simply buy another card than
>>> trying to get this fixed. So I bought a BCM43228 card, because it also
>>> supports 5 GHz. Only after it arrived I noticed that it was only
>>> supported by the 3.17+ kernel (not so much of a problem) and that it only
>>> seems to work in 802.11g mode (only slow speeds and no 5 GHz). At least I
>>> could use it in full 11g speeds, so it was a improvement.
>>>
>>> So I still don't have a card that does simply work. As I hope the missing
>>> support for my BCM43228 will hopefully be added some time in the future it
>>> probably would still be worth fixing the BCM4313 card as other users will
>>> also benefit from it.
>>>
>>> A friend of mine also has the same laptop than me and the same (or at
>>> least
>>> very similar) wireless card. He has told me he has also problem with
>>> stalls
>>> like Michael reported (if I remember the history of the thread correctly).
>>>
>>> So I'm not really sure where I should go from here. I can try to provide
>>> some debugging information as time permits, but I don't know how much
>>> time I will have for this in the future. Of course ideally I want to use
>>> the BCM43228 card with full support, as it can work on 5 GHz.
>>>
>>> Currently the BCM43228 card is plugged into my laptop, but I want to avoid
>>> swapping the cards more that very few times because the antenna connectors
>>> are only designed for very few (un)plug cycles.
>>>
>>> If it's of any information, my card is labeled BCM-BCM94313HMGB on the
>>> sticker, the laptop where it was originally is a ThinkPad Edge E135.
>>
>> Thanks for taking time to chime in. This chipset is a pain in the....
>> The label info does help. You have a 4313 with internal PA for which
>> support was added later. The card that Michael has seems to have an
>> external PA. The initial iPA support patch broke things for everyone
>> with external PA so it was reverted. In the second round it was better,
>> but it seems Michael still had issues. As he mentioned BT issues and his
>> card shares the external PA between WLAN and BT I believe that there is
>> a BT-coex issue.
>>
>> What is causing your 4313 to seemingly do 11g rates is hard to tell
>> without any debug info. I have that card over here, but in my cabled
>> setup it is doing 72Mbps, ie. 11n rate. I can run a rate-vs-range test
>> to see if there is an issue.
>>
>> Thanks again and
>> Regards,
>> Arend
>
> Hi Arend,
>
> Today I changed back to the BC4313 card to verify the speed is still slow. At
> first it was slow as I remembered it (down about 3 Mbits/s, up about 1 Mbit/s,
> measured with iperf).
> I then booted an Ubuntu Live image to try the wl driver, just to verify that
> it performs better and the hardware is still fine. First on the Ubuntu Live
> image the speed with the brcmsmac driver were the same as in my test above. I
> the installed the wl driver, unloaded the brcmsmac module and loaded the wl
> module. That however did not work as something in the kernel crashed and
> wireless didn't work at all. I rebootet the system to test again in case this
> was a random failure. What was interesting after this reboot was that the
> wireless connection was fast with the brcmsmac driver. I got about 35 Mbit/s
> up and down speed. I then tried the wl driver again but it still crashed.
>
> After this I rebooted into my normal Debian system and the brcmsmac driver was
> still fast. So what was different now than before. I realized that I always did
> a reboot, so the Laptop was never really off between the boots. I then shut
> down the laptop and waited a few seconds before turning it on again. And after
> that the driver was back to the slow speed.
>
> I did not verify this a second time, but for now it very much looks like the
> wl driver is settings something in the card that is necessary for getting
> faster speeds. This seems to be preserved on reboot but not on poweroff.
>
> I hope this my help you finding the problem in the brcmsmac driver. Feel free
> to ask if you need any addition debug information from me.
>
> And for the record, my atheros usb card is still much faster, it reaches
> 130 Mbit/s.

Thanks, Maximilian

I have been staring at differences brcmsmac and our internal driver 
(which wl is derived from as well). Would you be able to make an 
mmiotrace loading wl and brcmsmac.

Regards,
Arend
