From: Hans de Goede <hdegoede@redhat.com>
Subject: Re: [PATCH] dt: bindings: Add a generic ethernet device binding
Date: Sat, 16 Jul 2016 12:18:40 +0200
Message-ID: <289d5b2e-6232-2c91-f11d-774265e05125@redhat.com>
References: <1468405204-5845-1-git-send-email-hdegoede@redhat.com>
 <1788846.r3134d1VMR@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	devicetree <devicetree@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56651 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434AbcGPKSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jul 2016 06:18:46 -0400
In-Reply-To: <1788846.r3134d1VMR@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 15-07-16 22:42, Arnd Bergmann wrote:
> On Wednesday, July 13, 2016 12:20:04 PM CEST Hans de Goede wrote:
>> +&mmc1 {
>> +       non-removable;
>> +       status = "okay";
>> +
>> +       sdio_wifi: sdio_wifi@1 {
>> +               compatible = "generic,ethernet"
>> +               reg = <1>;
>> +       };
>> +};
>
> For discoverable buses, we normally use a compatible property that
> reflects the device ID on that bus, e.g. on PCI we have "pci1A2B:3C4D"
> and I think that makes more sense than having to come up with strings
> for sdio devices.

2 things:

1) The problem here is that different batches of the same board
(cheap chinese tablet) have different sdio wifi modules, so we
actually cannot specify a vendor / product id as in your example.

2) In some cases we do want an actual compatible because some devices
have some oob (out-of-band) going with e.g. gpio-s which cannot be
handled by mmc-pwrseq.

> In fact, Linux completely ignores the compatible strings on those
> buses (pci, usb, sdio, ...),

You're mostly right, but at least the brcmfmac driver looks for a
compatible in the mmc-host child node describing its sdio function
to see if it should check for oob irq information there.

> so I think we can just do the same thing
> using no compatible string at all.

I'm all for not using any compatible string at all, actually I submitted
a patch for a sunxi dt file which did that and Maxime pointed out that
the compatible is listed as Required in:
Documentation/devicetree/bindings/mmc/mmc-card.txt

If we can agree to make it optional, then I'll happily submit a patch
with that change and Maxime can take my sunxi dts patch as is :)

Regards,

Hans
