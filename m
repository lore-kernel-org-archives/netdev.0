From: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] dt: bindings: Add a generic ethernet device binding
Date: Fri, 15 Jul 2016 08:44:37 +0200
Message-ID: <ef2d70ca-ee49-9052-952d-f6a4daad92f9@redhat.com>
References: <1468405204-5845-1-git-send-email-hdegoede@redhat.com>
 <20160714.161707.2089949241813985527.davem@davemloft.net>
 <47a052a1-cc8b-0f75-e44a-450c4a0ac075@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47a052a1-cc8b-0f75-e44a-450c4a0ac075-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 15-07-16 08:40, Hans de Goede wrote:
> Hi,
>
> On 15-07-16 01:17, David Miller wrote:
>> From: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Date: Wed, 13 Jul 2016 12:20:04 +0200
>>
>>> On some boards (android tablets) different batches use different sdio
>>> wifi modules. This is not a problem since sdio is a discoverable bus,
>>> so we only need to describe and activate the mmc controller in dt and
>>> then the kernel will automatically load the right driver.
>>>
>>> But sometimes it is useful to specify certain ethernet properties for
>>> these "unknown" sdio devices, specifically we want the boot-loader
>>> to be able to set "local-mac-address" as some of these sdio wifi
>>> modules come without an eeprom / without a factory programmed mac
>>> address.
>>>
>>> Since the exact device is unknown (differs per batch) we cannot use
>>> a wifi-chip specific compatible. This commit adds a new
>>> "generic,ethernet" binding for use in dt-nodes describing such an
>>> unknown ethernet device.
>>>
>>> Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
>>> Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>
>> Precedence exists for a "system ethernet address" as far back as the
>> original sparc device tree implementation, so please just specify it
>> that way rather than trying to force having to make an alias or
>> reference to it from a specific device.
>
> Some boards where this is applicable have both a wired and a wireless
> ethernet, so one global setting will not work.

And besides that, everything used in this binding already exists, it
just adds a new "generic,ethernet" compatible, because e.g. the mmc
bindings specify that the node describing a sdio function _must_
have a compatible, and as explained in some cases we cannot use
a compatible for a specific wifi chip since different batches use
different wifi modules.

About the use of "generic,ethernet" looking at the simple-framebuffer
binding I guess it should be just "ethernet".

Regards,

Hans
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
