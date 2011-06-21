From: Mitch Bradley <wmb-D5eQfiDGL7eakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Tue, 21 Jun 2011 09:35:44 -1000
Message-ID: <4E00F290.2010303@firmworks.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>	<1308410354-21387-2-git-send-email-shawn.guo@linaro.org>	<20110618161934.GH8195@ponder.secretlab.ca>	<20110619073000.GA23171@S2100-06.ap.freescale.net>	<20110621135558.GB9228@S2101-09.ap.freescale.net>
	<BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Jeremy Kerr <jeremy.kerr-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <BANLkTim4vunTm1176MRw3pqRZnunu4=9jg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

What is the problem with

aliases{
    serial0 = "/uart@7000c000";
}

Properties in the alias node are supposed to have string values.


On 6/21/2011 9:13 AM, Grant Likely wrote:
> On Tue, Jun 21, 2011 at 7:55 AM, Shawn Guo<shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org>  wrote:
>> Hi Grant,
>>
>> I just gave a try to use aliases node for identify the device index.
>> Please take a look and let me know if it's what you expect.
>
> Thanks Shawn.  This is definitely on track.  Comments below...
>
>>
>> On Sun, Jun 19, 2011 at 03:30:02PM +0800, Shawn Guo wrote:
>> [...]
>>>>>
>>>>> +#ifdef CONFIG_OF
>>>>> +static int serial_imx_probe_dt(struct imx_port *sport,
>>>>> +         struct platform_device *pdev)
>>>>> +{
>>>>> + struct device_node *node = pdev->dev.of_node;
>>>>> + const __be32 *line;
>>>>> +
>>>>> + if (!node)
>>>>> +         return -ENODEV;
>>>>> +
>>>>> + line = of_get_property(node, "id", NULL);
>>>>> + if (!line)
>>>>> +         return -ENODEV;
>>>>> +
>>>>> + sport->port.line = be32_to_cpup(line) - 1;
>>>>
>>>> Hmmm, I really would like to be rid of this.  Instead, if uarts must
>>>> be enumerated, the driver should look for a /aliases/uart* property
>>>> that matches the of_node.  Doing it that way is already established in
>>>> the OpenFirmware documentation, and it ensures there are no overlaps
>>>> in the global namespace.
>>>>
>>>
>>> I just gave one more try to avoid using 'aliases', and you gave a
>>> 'no' again.  Now, I know how hard you are on this.  Okay, I start
>>> thinking about your suggestion seriously :)
>>>
>>>> We do need some infrastructure to make that easier though.  Would you
>>>> have time to help put that together?
>>>>
>>> Ok, I will give it a try.
>>>
>>
>> diff --git a/arch/arm/boot/dts/imx51-babbage.dts b/arch/arm/boot/dts/imx51-babbage.dts
>> index da0381a..f4a5c3c 100644
>> --- a/arch/arm/boot/dts/imx51-babbage.dts
>> +++ b/arch/arm/boot/dts/imx51-babbage.dts
>> @@ -18,6 +18,12 @@
>>         compatible = "fsl,imx51-babbage", "fsl,imx51";
>>         interrupt-parent =<&tzic>;
>>
>> +       aliases {
>> +               serial0 =&uart0;
>> +               serial1 =&uart1;
>> +               serial2 =&uart2;
>> +       };
>> +
>
> Hmmm.  David Gibson had tossed out an idea of automatically generating
> aliases from labels.  It may be time to revisit that idea.
>
> David, perhaps using this format for a label should turn it into an
> alias (prefix label with an asterisk):
>
>          *thealias: i2c@12340000 { /*...*/ };
>
> .... although that approach gets *really* hairy when considering that
> different boards will want different enumeration.  How would one
> override an automatic alias defined by an included .dts file?
>
>>         chosen {
>>                 bootargs = "console=ttymxc0,115200 root=/dev/mmcblk0p3 rootwait";
>>         };
>> @@ -47,29 +53,29 @@
>>                         reg =<0x70000000 0x40000>;
>>                         ranges;
>>
>> -                       uart@7000c000 {
>> +                       uart2: uart@7000c000 {
>>                                 compatible = "fsl,imx51-uart", "fsl,imx21-uart";
>>                                 reg =<0x7000c000 0x4000>;
>>                                 interrupts =<33>;
>>                                 id =<3>;
>> -                               fsl,has-rts-cts;
>> +                               fsl,uart-has-rtscts;
>>                         };
>>                 };
>>
>> -               uart@73fbc000 {
>> +               uart0: uart@73fbc000 {
>>                         compatible = "fsl,imx51-uart", "fsl,imx21-uart";
>>                         reg =<0x73fbc000 0x4000>;
>>                         interrupts =<31>;
>>                         id =<1>;
>> -                       fsl,has-rts-cts;
>> +                       fsl,uart-has-rtscts;
>>                 };
>>
>> -               uart@73fc0000 {
>> +               uart1: uart@73fc0000 {
>>                         compatible = "fsl,imx51-uart", "fsl,imx21-uart";
>>                         reg =<0x73fc0000 0x4000>;
>>                         interrupts =<32>;
>>                         id =<2>;
>> -                       fsl,has-rts-cts;
>> +                       fsl,uart-has-rtscts;
>>                 };
>>         };
>>
>> diff --git a/drivers/of/base.c b/drivers/of/base.c
>> index 632ebae..13df5d2 100644
>> --- a/drivers/of/base.c
>> +++ b/drivers/of/base.c
>> @@ -737,6 +737,37 @@ err0:
>>   EXPORT_SYMBOL(of_parse_phandles_with_args);
>>
>>   /**
>> + *     of_get_device_index - Get device index by looking up "aliases" node
>> + *     @np:    Pointer to device node that asks for device index
>> + *     @name:  The device alias without index number
>> + *
>> + *     Returns the device index if find it, else returns -ENODEV.
>> + */
>> +int of_get_device_index(struct device_node *np, const char *alias)
>> +{
>> +       struct device_node *aliases = of_find_node_by_name(NULL, "aliases");
>> +       struct property *prop;
>> +       char name[32];
>> +       int index = 0;
>> +
>> +       if (!aliases)
>> +               return -ENODEV;
>> +
>> +       while (1) {
>> +               snprintf(name, sizeof(name), "%s%d", alias, index);
>> +               prop = of_find_property(aliases, name, NULL);
>> +               if (!prop)
>> +                       return -ENODEV;
>> +               if (np == of_find_node_by_path(prop->value))
>> +                       break;
>> +               index++;
>> +       }
>
> Rather than parsing the alias strings everytime, it would probably be
> better to preprocess all the properties in the aliases node and create
> a lookup table of alias->node references that can be walked quickly
> and trivially.
>
> Also, when obtaining an enumeration for a device, you'll need to be
> careful about what number gets returned.  If the node doesn't match a
> given alias, but aliases do exist for other devices of like type, then
> you need to be careful not to assign a number already assigned to
> another device via an alias (this of course assumes the driver
> supports dynamics enumeration, which many drivers will).  It would be
>
> \>  +
>> +       return index;
>> +}
>> +EXPORT_SYMBOL(of_get_device_index);
>> +
>> +/**
>>   * prom_add_property - Add a property to a node
>>   */
>>   int prom_add_property(struct device_node *np, struct property *prop)
>> diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
>> index da436e0..852668f 100644
>> --- a/drivers/tty/serial/imx.c
>> +++ b/drivers/tty/serial/imx.c
>> @@ -1271,18 +1271,18 @@ static int serial_imx_probe_dt(struct imx_port *sport,
>>         struct device_node *node = pdev->dev.of_node;
>>         const struct of_device_id *of_id =
>>                         of_match_device(imx_uart_dt_ids,&pdev->dev);
>> -       const __be32 *line;
>> +       int line;
>>
>>         if (!node)
>>                 return -ENODEV;
>>
>> -       line = of_get_property(node, "id", NULL);
>> -       if (!line)
>> +       line = of_get_device_index(node, "serial");
>> +       if (IS_ERR_VALUE(line))
>>                 return -ENODEV;
>
> Personally, it an alias isn't present, then I'd dynamically assign a port id.
>
>>
>> -       sport->port.line = be32_to_cpup(line) - 1;
>> +       sport->port.line = line;
>>
>> -       if (of_get_property(node, "fsl,has-rts-cts", NULL))
>> +       if (of_get_property(node, "fsl,uart-has-rtscts", NULL))
>>                 sport->have_rtscts = 1;
>>
>>         if (of_get_property(node, "fsl,irda-mode", NULL))
>> diff --git a/include/linux/of.h b/include/linux/of.h
>> index bfc0ed1..3153752 100644
>> --- a/include/linux/of.h
>> +++ b/include/linux/of.h
>> @@ -213,6 +213,8 @@ extern int of_parse_phandles_with_args(struct device_node *np,
>>         const char *list_name, const char *cells_name, int index,
>>         struct device_node **out_node, const void **out_args);
>>
>> +extern int of_get_device_index(struct device_node *np, const char *alias);
>> +
>>   extern int of_machine_is_compatible(const char *compat);
>>
>>   extern int prom_add_property(struct device_node* np, struct property* prop);
>>
>> --
>> Regards,
>> Shawn
>>
>>
>
>
>
