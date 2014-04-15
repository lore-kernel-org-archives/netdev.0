From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: Re: [PATCH 7/7] ARM: sun7i: cubietruck: enable
 bluetooth module
Date: Wed, 16 Apr 2014 00:06:59 +0800
Message-ID: <CAGb2v643HyvFdhQ0znreB8ENXHWpcx6tFwdeU7VuU8KYWcT4ZA@mail.gmail.com>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
 <1397544101-18135-8-git-send-email-wens@csie.org> <20140415144215.GG3207@lukather>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>, linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBN5SWWNAKGQEUU3ISKI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20140415144215.GG3207@lukather>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, Apr 15, 2014 at 10:42 PM, Maxime Ripard
<maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
> On Tue, Apr 15, 2014 at 02:41:41PM +0800, Chen-Yu Tsai wrote:
>> The CubieTruck has an AMPAK AP6210 WiFi+Bluetooth module. The Bluetooth
>> part is a BCM20710 device connected to UART2 in the A20 SoC.
>>
>> The IC requires a 32.768 KHz low power clock input for proper
>> auto-detection of the main clock, and an enable signal via GPIO.
>>
>> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
>> ---
>>  arch/arm/boot/dts/sun7i-a20-cubietruck.dts | 25 +++++++++++++++++++++++++
>>  1 file changed, 25 insertions(+)
>>
>> diff --git a/arch/arm/boot/dts/sun7i-a20-cubietruck.dts b/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
>> index cb25d3c..767c8e1 100644
>> --- a/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
>> +++ b/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
>> @@ -61,6 +61,13 @@
>>                               allwinner,drive = <0>;
>>                               allwinner,pull = <0>;
>>                       };
>> +
>> +                     bt_pwr_pin_cubietruck: bt_pwr_pin@0 {
>> +                             allwinner,pins = "PH18";
>> +                             allwinner,function = "gpio_out";
>> +                             allwinner,drive = <0>;
>> +                             allwinner,pull = <0>;
>> +                     };
>>               };
>>
>>               uart0: serial@01c28000 {
>> @@ -69,6 +76,12 @@
>>                       status = "okay";
>>               };
>>
>> +             uart2: serial@01c28800 {
>> +                     pinctrl-names = "default";
>> +                     pinctrl-0 = <&uart2_pins_a>;
>> +                     status = "okay";
>> +             };
>> +
>
> Please make this a separate patch.

Will do.

>>               i2c0: i2c@01c2ac00 {
>>                       pinctrl-names = "default";
>>                       pinctrl-0 = <&i2c0_pins_a>;
>> @@ -139,4 +152,16 @@
>>       reg_usb2_vbus: usb2-vbus {
>>               status = "okay";
>>       };
>> +
>> +     rfkill_bt {
>> +             compatible = "rfkill-gpio";
>> +             pinctrl-names = "default";
>> +             pinctrl-0 = <&bt_pwr_pin_cubietruck>, <&clk_out_a_pins_a>;
>> +             clocks = <&clk_out_a>;
>> +             clock-frequency = <32768>;
>> +             gpios = <&pio 7 18 0>; /* PH18 */
>> +             gpio-names = "reset";
>> +             rfkill-name = "bt";
>> +             rfkill-type = <2>;
>> +     };
>
> Hmmm, I don't think that's actually right.
>
> If you have such a device, then I'd expect it to be represented as a
> full device in the DT, probably with one part for the WiFi, one part
> for the Bluetooth, and here the definition of the rfkill device that
> controls it.

The AP6210 is not one device, but 2 separate chips in one module. Each
chip has its own controls and interface. They just so happen to share
the same enclosure. Even 2-in-1 chips by Broadcom have separate controls
and interfaces. The WiFi side is most likely connected via SDIO, while
the Bluetooth side is connected to a UART, and optionally I2S for sound.

> But tying parts of the device to the rfkill that controls it, such as
> the clocks, or the frequency it runs at seems just wrong.

I understand where you're coming from. For devices on buses that require
drivers (such as USB, SDIO) these properties probably should be tied to
the device node.

For our use case here, which is a bluetooth chip connected on the UART,
there is no in kernel representation or driver to tie them to. Same goes
for UART based GPS chips. They just so happen to require toggling a GPIO,
and maybe enabling a specific clock, to get it running. Afterwards,
accessing it is done solely from userspace. For our Broadcom chips, the
user has to upload its firmware first, then designate the tty as a Bluetooth
HCI using hciattach.

We are using the rfkill device as a on-off switch.

Hope this explains the situation.


Cheers
ChenYu
