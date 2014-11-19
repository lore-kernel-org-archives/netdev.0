From: Arend van Spriel <arend@broadcom.com>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Wed, 19 Nov 2014 14:46:19 +0100
Message-ID: <546C9F2B.8090104@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <54363ED0.605@broadcom.com> <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com> <3543341.FmUQFH9nrl@eisbaer>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Michael Tokarev <mjt@tls.msk.ru>,
	Seth Forshee <seth.forshee@canonical.com>,
	"brcm80211 development" <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Network Development" <netdev@vger.kernel.org>
To: Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:58931 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbaKSNqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 08:46:24 -0500
In-Reply-To: <3543341.FmUQFH9nrl@eisbaer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/14 23:36, Maximilian Engelhardt wrote:
> On Thursday 09 October 2014 10:21:12 Rafa=C5=82 Mi=C5=82ecki wrote:
>> On 9 October 2014 09:52, Arend van Spriel<arend@broadcom.com>  wrote=
:
>>> I have been staring at differences brcmsmac and our internal driver=
 (which
>>> wl is derived from as well). Would you be able to make an mmiotrace
>>> loading
>>> wl and brcmsmac.
>>
>> Arend,
>>
>> As you noticed earlier, this is a WiFi card with BT. I've checked
>> siutils.c from SDK 7.14.43.7 (got it from Netgear R8000) and it has
>> three BCM4313 workarounds:
>>
>>
>> 1) si_doattach
>> SI_MSG(("Applying 4313 WARs\n"));
>> si_pmu_chipcontrol(sih, 0, CCTRL_4313_12MA_LED_DRIVE,
>> CCTRL_4313_12MA_LED_DRIVE);
>>
>> It's already implemented in bcma, see driver_chipcommon_pmu.c
>>
>>
>> 2) si_epa_4313war
>> /* EPA Fix */
>> W_REG(sii->osh,&cc->gpiocontrol,
>> R_REG(sii->osh,&cc->gpiocontrol) | GPIO_CTRL_EPA_EN_MASK);
>>
>> This is what you already implement in ai_epa_4313war
>>
>>
>> 3) si_pmu_synth_pwrsw_4313_war
>> I don't think it's implemented.
>>
>>
>> 4) si_btcombo_p250_4313_war
>> I also don't think it's implemented
>>
>>
>> The last one (si_btcombo_p250_4313_war) looks promising, the comment
>> above the function says:
>> /** WL/BT control for 4313 btcombo boards>=3D P250 */
>> I guess you need to re-implement this function and call it somewhere
>> in brcmsmac.
>
> Hi,
>
> I just wanted to ask if there is any progress on this issue since I h=
aven't
> heard anything for a month. Please let me know if you need any additi=
onal
> information.

I had a bit of problem with the mmiotrace files. Well, my (virtual)=20
linux machine had as it ended up swapping on my disk and went down the=20
drain.

I still wanted to look at items 3) and 4) that Rafal mentioned although=
=20
item 4) does not seems to apply to Michael's 4313 it may help yours. I=20
submitted a patch to get counter statistics from the 802.11 core on the=
=20
chip [1] as I am curious whether that will show a possible lead.

Regards,
Arend
