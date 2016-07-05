From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 6/7] dt-bindings: net: bgmac: add bindings documentation
 for bgmac
Date: Tue, 5 Jul 2016 19:18:45 -0400
Message-ID: <CAC3K-4qZ9tpEAuDBjL-bkjn5F2Xfr4CAmVGc=DpgVh8MrqEDtQ@mail.gmail.com>
References: <1467327554-22074-1-git-send-email-jon.mason@broadcom.com>
 <6488341.IDGze89kcW@wuerfel> <e8ba3130-38ff-3d67-da64-f7c15ec27ded@broadcom.com>
 <3327458.KVBg7y9SeP@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Ray Jui <ray.jui@broadcom.com>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Branden <sbranden@broadcom.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	linux-kernel@vger.kernel.org, Ray Jui <rjui@broadcom.com>,
	Rob Herring <robh+dt@kernel.org>,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	Kumar Gala <galak@codeaurora.org>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3327458.KVBg7y9SeP@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 5, 2016 at 9:37 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Monday, July 4, 2016 9:34:35 AM CEST Ray Jui wrote:
>> On 7/1/2016 8:42 AM, Arnd Bergmann wrote:
>> > On Friday, July 1, 2016 11:17:25 AM CEST Jon Mason wrote:
>> >> On Fri, Jul 1, 2016 at 5:46 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>> >>> On Thursday, June 30, 2016 6:59:13 PM CEST Jon Mason wrote:
>> >>>> +
>> >>>> +Required properties:
>> >>>> + - compatible: "brcm,bgmac-nsp"
>> >>>> + - reg:                Address and length of the GMAC registers,
>> >>>> +               Address and length of the GMAC IDM registers
>> >>>> + - reg-names:  Names of the registers.  Must have both "gmac_base" and
>> >>>> +               "idm_base"
>> >>>> + - interrupts: Interrupt number
>> >>>> +
>> >>>
>> >>>
>> >>> "brcm,bgmac-nsp" sounds a bit too general. As I understand, this is a family
>> >>> of SoCs that might not all have the exact same implementation of this
>> >>> ethernet device, as we can see from the long lookup table in bgmac_probe().
>> >>
>> >> The Broadcom iProc family of SoCs contains:
>> >> Northstar
>> >> Northstar Plus
>> >> Cygnus
>> >> Northstar 2
>> >> a few SoCs that are under development
>> >> and a number of ethernet switches (which might never be officially supported)
>> >>
>> >> Each one of these SoCs could have a different revision of the gmac IP
>> >> block, but they should be uniform within each SoC (though there might
>> >> be a A0/B0 change necessary).  The Northstar Plus product family has a
>> >> number of different implementations, but the SoC is unchanged.  So, I
>> >> think this might be too specific, when we really need a general compat
>> >> string.
>> >
>> > Ok, thanks for the clarification, that sounds good enough.
>> >
>> >> Broadcom has a history of sharing IP blocks amongst the different
>> >> divisions.  So, this driver might be used on other SoC families (as it
>> >> apparently has been done in the past, based on the code you
>> >> reference).  I do not know of any way to know what legacy, non-iProc
>> >> chips have used this IP block.  I can make this "brcm,iproc-bgmac",
>> >> and add "brcm,iproc-nsp-bgmac" as an alternative compatible string in
>> >> this file (which I believe you are suggesting), but there might be
>> >> non-iProc SoCs that use this driver.  Is this acceptable?
>> >
>> > If it is also used outside of iProc, then I see no need for the
>> > extra compatible string, although it would not do any harm either.
>> >
>> > Ideally we should name it whatever the name for this IP block is
>> > inside of the company, with "nsp" as the designation for the variant
>> > in Northstar Plus. A lot of Broadcom IP blocks themselves seem to have
>> > some four-digit or five-digit number, maybe this one does too?
>> >
>> >       Arnd
>> >
>>
>> Note this IP block has an official IP controller name of "amac" from the
>> ASIC team.
>
> Ok, then I'd suggest making the compatible string here
>
>         compatible = "brcm,nsp-amac", "brcm,amac";

It is called GMAC in the NS and NSP documentation, but AMAC is fine
with me (as it is called this in the NS2 documentation).  I'll make
the necessary change and repush.

Thanks for all of the input.

> or even better if you have a version number associated with it, make that
>
>         compatible = "brcm,nsp-amac", "brcm,amac-1.234", "brcm,amac";
>
> replacing 1.234 with the actual version of course.
>
>         Arnd
>
