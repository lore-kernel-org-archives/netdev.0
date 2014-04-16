From: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Re: [PATCH 7/7] ARM: sun7i: cubietruck: enable
 bluetooth module
Date: Wed, 16 Apr 2014 15:09:22 +0200
Message-ID: <534E8102.4070404@redhat.com>
References: <1397544101-18135-1-git-send-email-wens@csie.org> <1397544101-18135-8-git-send-email-wens@csie.org> <20140415144215.GG3207@lukather> <CAGb2v643HyvFdhQ0znreB8ENXHWpcx6tFwdeU7VuU8KYWcT4ZA@mail.gmail.com> <20140416094428.GK3207@lukather> <CAGb2v67HzB22a3huRRZyufXkdTFE410MhXqAHyC-MmVo0-GCFA@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
        "linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <linux-sunxi+bncBDL4X2GMZUKRBFUCXKNAKGQEB4P373I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <CAGb2v67HzB22a3huRRZyufXkdTFE410MhXqAHyC-MmVo0-GCFA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

On 04/16/2014 12:39 PM, Chen-Yu Tsai wrote:
> Hi,
> 
> On Wed, Apr 16, 2014 at 5:44 PM, Maxime Ripard
> <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
>> Hi,
>>
>> Please try to keep me in CC, even though the ML doesn't make it easy..
> 
> Sorry about that.
> 
>> On Wed, Apr 16, 2014 at 12:06:59AM +0800, Chen-Yu Tsai wrote:
>>>>> @@ -139,4 +152,16 @@
>>>>>       reg_usb2_vbus: usb2-vbus {
>>>>>               status = "okay";
>>>>>       };
>>>>> +
>>>>> +     rfkill_bt {
>>>>> +             compatible = "rfkill-gpio";
>>>>> +             pinctrl-names = "default";
>>>>> +             pinctrl-0 = <&bt_pwr_pin_cubietruck>, <&clk_out_a_pins_a>;
>>>>> +             clocks = <&clk_out_a>;
>>>>> +             clock-frequency = <32768>;
>>>>> +             gpios = <&pio 7 18 0>; /* PH18 */
>>>>> +             gpio-names = "reset";
>>>>> +             rfkill-name = "bt";
>>>>> +             rfkill-type = <2>;
>>>>> +     };
>>>>
>>>> Hmmm, I don't think that's actually right.
>>>>
>>>> If you have such a device, then I'd expect it to be represented as a
>>>> full device in the DT, probably with one part for the WiFi, one part
>>>> for the Bluetooth, and here the definition of the rfkill device that
>>>> controls it.
>>>
>>> The AP6210 is not one device, but 2 separate chips in one module. Each
>>> chip has its own controls and interface. They just so happen to share
>>> the same enclosure. Even 2-in-1 chips by Broadcom have separate controls
>>> and interfaces. The WiFi side is most likely connected via SDIO, while
>>> the Bluetooth side is connected to a UART, and optionally I2S for sound.
>>
>> It's even easier to represent then.
>>
>>>> But tying parts of the device to the rfkill that controls it, such as
>>>> the clocks, or the frequency it runs at seems just wrong.
>>>
>>> I understand where you're coming from. For devices on buses that require
>>> drivers (such as USB, SDIO) these properties probably should be tied to
>>> the device node.
>>>
>>> For our use case here, which is a bluetooth chip connected on the UART,
>>> there is no in kernel representation or driver to tie them to. Same goes
>>> for UART based GPS chips. They just so happen to require toggling a GPIO,
>>> and maybe enabling a specific clock, to get it running. Afterwards,
>>> accessing it is done solely from userspace. For our Broadcom chips, the
>>> user has to upload its firmware first, then designate the tty as a Bluetooth
>>> HCI using hciattach.
>>>
>>> We are using the rfkill device as a on-off switch.
>>
>> I understand your point, but the fact that it's implemented in
>> user-space, or that UART is not a bus (which probably should be), is
>> only a Linux specific story, and how it's implemented in Linux (even
>> if the whole rfkill node is another one, but let's stay on topic).
> 
> I gave it some thought last night. You are right. My whole approach
> is wrong. But let's try to make it right.
> 
> So considering the fact that it's primarily connected to a UART,
> maybe I should make it a sub-node to the UART node it's actually
> connected to? Something like:
> 
>         uart2: serial@01c28800 {
>                 pinctrl-names = "default";
>                 pinctrl-0 = <&uart2_pins_a>;
>                 status = "okay";
> 
>                 bt: bt_hci {
>                         compatible = "brcm,bcm20710";
>                         /* maybe add some generic compatible */
>                         pinctrl-names = "default";
>                         pinctrl-0 = <&clk_out_a_pins_a>,
> <&bt_pwr_pin_cubietruck>;
>                         clocks = <&clk_out_a>;
>                         clock-frequency = <32768>;
>                         gpios = <&pio 7 18 0>; /* PH18 */
>                 };
>         };
> 
> And let the uart core handle power sequencing for sub-nodes.

Great, I missed this reply when I typed my mail I send a few minutes
ago. I agree that this approach is how thing should be.

Regards,

Hans
