From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] brcmfmac: fix setting AP channel with new firmwares
Date: Wed, 25 May 2016 23:49:42 +0200
Message-ID: <CACna6rxYaOtdjGwVenhz66khNMdpqvnbZWfNupBwtp13hbXfBg@mail.gmail.com>
References: <1464080979-12150-1-git-send-email-zajec5@gmail.com>
	<57461435.9080708@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<linux-wireless@vger.kernel.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list@broadcom.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57461435.9080708@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25 May 2016 at 23:08, Arend van Spriel <arend.vanspriel@broadcom.com=
> wrote:
> On 24-05-16 11:09, Rafa=C5=82 Mi=C5=82ecki wrote:
>> Firmware for new chipsets is based on a new major version of code
>> internally maintained at Broadcom. E.g. brcmfmac4366b-pcie.bin (used=
 for
>> BCM4366B1) is based on 10.10.69.3309 while brcmfmac43602-pcie.ap.bin=
 was
>> based on 7.35.177.56.
>>
>> Currently setting AP 5 GHz channel doesn't work reliably with BCM436=
6B1.
>> When setting e.g. 36 control channel with VHT80 (center channel 42)
>> firmware may randomly pick one of:
>> 1) 52 control channel with 58 as center one
>> 2) 100 control channel with 106 as center one
>> 3) 116 control channel with 122 as center one
>> 4) 149 control channel with 155 as center one
>>
>> It seems new firmwares require setting AP mode (BRCMF_C_SET_AP) befo=
re
>> specifying a channel. Changing an order of firmware calls fixes the
>> problem.
>>
>> This fix was verified with BCM4366B1 and tested for regressions on
>> BCM43602. It's unclear if it's needed (or correct at all) for P2P
>> interfaces so it leaves this code unaffected.
>
> In doing so the code reads a bit awkward so if P2P-GO works with the
> changed order that would be preferable.

I'd prefer to have one code path as well, but my device/firmware
doesn't support P2P so I couldn't test it.

Could you test it or check firmware code to see if it's safe to change
P2P path as well?

--=20
Rafa=C5=82
