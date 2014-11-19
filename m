From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Wed, 19 Nov 2014 14:49:29 +0100
Message-ID: <546C9FE9.60100@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <54363ED0.605@broadcom.com> <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com> <3543341.FmUQFH9nrl@eisbaer> <546C9F2B.8090104@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"brcm80211 development" <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Network Development" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <546C9F2B.8090104-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/19/14 14:46, Arend van Spriel wrote:
> On 11/17/14 23:36, Maximilian Engelhardt wrote:
>> On Thursday 09 October 2014 10:21:12 Rafa=C5=82 Mi=C5=82ecki wrote:
>>> On 9 October 2014 09:52, Arend van Spriel<arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote=
:
>>>> I have been staring at differences brcmsmac and our internal drive=
r
>>>> (which
>>>> wl is derived from as well). Would you be able to make an mmiotrac=
e
>>>> loading
>>>> wl and brcmsmac.
>>>
>>> Arend,
>>>
>>> As you noticed earlier, this is a WiFi card with BT. I've checked
>>> siutils.c from SDK 7.14.43.7 (got it from Netgear R8000) and it has
>>> three BCM4313 workarounds:
>>>
>>>
>>> 1) si_doattach
>>> SI_MSG(("Applying 4313 WARs\n"));
>>> si_pmu_chipcontrol(sih, 0, CCTRL_4313_12MA_LED_DRIVE,
>>> CCTRL_4313_12MA_LED_DRIVE);
>>>
>>> It's already implemented in bcma, see driver_chipcommon_pmu.c
>>>
>>>
>>> 2) si_epa_4313war
>>> /* EPA Fix */
>>> W_REG(sii->osh,&cc->gpiocontrol,
>>> R_REG(sii->osh,&cc->gpiocontrol) | GPIO_CTRL_EPA_EN_MASK);
>>>
>>> This is what you already implement in ai_epa_4313war
>>>
>>>
>>> 3) si_pmu_synth_pwrsw_4313_war
>>> I don't think it's implemented.
>>>
>>>
>>> 4) si_btcombo_p250_4313_war
>>> I also don't think it's implemented
>>>
>>>
>>> The last one (si_btcombo_p250_4313_war) looks promising, the commen=
t
>>> above the function says:
>>> /** WL/BT control for 4313 btcombo boards>=3D P250 */
>>> I guess you need to re-implement this function and call it somewher=
e
>>> in brcmsmac.
>>
>> Hi,
>>
>> I just wanted to ask if there is any progress on this issue since I
>> haven't
>> heard anything for a month. Please let me know if you need any addit=
ional
>> information.
>
> I had a bit of problem with the mmiotrace files. Well, my (virtual)
> linux machine had as it ended up swapping on my disk and went down th=
e
> drain.
>
> I still wanted to look at items 3) and 4) that Rafal mentioned althou=
gh
> item 4) does not seems to apply to Michael's 4313 it may help yours. =
I
> submitted a patch to get counter statistics from the 802.11 core on t=
he
> chip [1] as I am curious whether that will show a possible lead.
>
> Regards,
> Arend

+ links

patch [1] depends on patch [2]

[1]=20
https://git.kernel.org/cgit/linux/kernel/git/linville/wireless-next.git=
/commit/drivers/net/wireless/brcm80211?id=3D3fe33c4ce
[2]=20
https://git.kernel.org/cgit/linux/kernel/git/linville/wireless-next.git=
/commit/drivers/net/wireless/brcm80211?id=3D9146782b1b
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
