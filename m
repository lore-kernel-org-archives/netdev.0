From: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/8] tty/bcm63xx_uart: allow naming clock in device tree
Date: Wed, 6 Sep 2017 14:37:27 +0200
Message-ID: <CAOiHx==oPYiALNL-cHNWCH+YMFswJt4uz-ob++5z+hMauWuRqQ@mail.gmail.com>
References: <20170802093429.12572-1-jonas.gorski@gmail.com>
 <20170802093429.12572-5-jonas.gorski@gmail.com> <CAOiHx=mC=GfX0VvuRWR-AmXYfVOEkuruwGHooS08WrL_z-60UA@mail.gmail.com>
 <20170906121715.GA27869@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: MIPS Mailing List <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        bcm-kernel-feedback-list <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Kevin Cernekee <cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170906121715.GA27869-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 6 September 2017 at 14:17, Greg Kroah-Hartman
<gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:
> On Wed, Sep 06, 2017 at 01:01:32PM +0200, Jonas Gorski wrote:
>> Hi Greg,
>>
>> On 2 August 2017 at 11:34, Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> > Codify using a named clock for the refclk of the uart. This makes it
>> > easier if we might need to add a gating clock (like present on the
>> > BCM6345).
>> >
>> > Signed-off-by: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>
>> Could I please get a (N)Ack so Ralf can add this patch to his tree?
>>
>>
>> Regards
>> Jonas
>>
>>
>> > ---
>> >  Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt | 6 ++++++
>> >  drivers/tty/serial/bcm63xx_uart.c                              | 6 ++++--
>> >  2 files changed, 10 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt b/Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt
>> > index 5c52e5eef16d..8b2b0460259a 100644
>> > --- a/Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt
>> > +++ b/Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt
>> > @@ -11,6 +11,11 @@ Required properties:
>> >  - clocks: Clock driving the hardware; used to figure out the baud rate
>> >    divisor.
>> >
>> > +
>> > +Optional properties:
>> > +
>> > +- clock-names: Should be "refclk".
>> > +
>> >  Example:
>> >
>> >         uart0: serial@14e00520 {
>> > @@ -19,6 +24,7 @@ Example:
>> >                 interrupt-parent = <&periph_intc>;
>> >                 interrupts = <2>;
>> >                 clocks = <&periph_clk>;
>> > +               clock-names = "refclk";
>> >         };
>> >
>> >         clocks {
>
> I don't ack devtree changes :)
>
>> > diff --git a/drivers/tty/serial/bcm63xx_uart.c b/drivers/tty/serial/bcm63xx_uart.c
>> > index a2b9376ec861..f227eff28d3a 100644
>> > --- a/drivers/tty/serial/bcm63xx_uart.c
>> > +++ b/drivers/tty/serial/bcm63xx_uart.c
>> > @@ -841,8 +841,10 @@ static int bcm_uart_probe(struct platform_device *pdev)
>> >         if (!res_irq)
>> >                 return -ENODEV;
>> >
>> > -       clk = pdev->dev.of_node ? of_clk_get(pdev->dev.of_node, 0) :
>> > -                                 clk_get(&pdev->dev, "refclk");
>> > +       clk = clk_get(&pdev->dev, "refclk");
>> > +       if (IS_ERR(clk) && pdev->dev.of_node)
>> > +               clk = of_clk_get(pdev->dev.of_node, 0);
>> > +
>> >         if (IS_ERR(clk))
>> >                 return -ENODEV;
>> >
>
> This part is fine with me:

That's all I wanted :)
>
> Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>

Thank you!


Jonas
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
