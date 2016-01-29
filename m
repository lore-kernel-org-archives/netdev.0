From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Fri, 29 Jan 2016 14:10:07 -0600
Message-ID: <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
 <20151231231039.GA8886@rob-hp-laptop> <56ABADEA.40801@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-msm <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sagar Dharia <sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56ABADEA.40801-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 29, 2016 at 12:22 PM, Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> Gilad is no longer working for Qualcomm, so I'm taking over (as best as I
> can) this driver.  Let's just say it's going to be a learning experience.

Lucky you.

> Rob Herring wrote:
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/qcom-emac.txt
>>> b/Documentation/devicetree/bindings/net/qcom-emac.txt
>>> new file mode 100644
>>> index 0000000..8d58a40
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
>>> @@ -0,0 +1,68 @@
>>> +Qualcomm EMAC Gigabit Ethernet Controller
>>> +
>>> +Required properties:
>>> +- cell-index : EMAC controller instance number.
>>> +- compatible : Should be "qcom,emac".
>>
>>
>> This should be more specific with the SOC name.
>
>
> The emac is present on a lot of Qualcomm SOCs, and there are only a few
> variations of it.  It's not really SOC-specific, and the hardware version
> can be queried by the driver.

Can the integration bugs be queried, too?

Come on, you know how compatible strings work.

> What did you have in mind?  I don't know even have a list of which SOCs has
> an emac, especially since it's mostly on MSM parts, and I work on the server
> SOC.

You only need the one you care about. Figure out the part number
already. Or find the closest MSM part.

>>> +- reg : Offset and length of the register regions for the device
>>> +- reg-names : Register region names referenced in 'reg' above.
>>> +       Required register resource entries are:
>>> +       "base"   : EMAC controller base register block.
>>> +       "csr"    : EMAC wrapper register block.
>>> +       Optional register resource entries are:
>>> +       "ptp"    : EMAC PTP (1588) register block.
>>> +                  Required if 'qcom,emac-tstamp-en' is present.
>>> +       "sgmii"  : EMAC SGMII PHY register block.
>>> +- interrupts : Interrupt numbers used by this controller
>>> +- interrupt-names : Interrupt resource names referenced in 'interrupts'
>>> above.
>>> +       Required interrupt resource entries are:
>>> +       "emac_core0"   : EMAC core0 interrupt.
>>> +       "sgmii_irq"   : EMAC SGMII interrupt.
>>> +- qcom,emac-gpio-mdc  : GPIO pin number of the MDC line of MDIO bus.
>>> +- qcom,emac-gpio-mdio : GPIO pin number of the MDIO line of MDIO bus.
>>
>>
>> Use the standard binding for GPIO controlled MDIO bus.
>
>
> I'm not familiar with that one.  Are you talking about
> bindings/net/mdio-gpio.txt?

Yes.


>>> +- phy-addr            : Specifies phy address on MDIO bus.
>>> +                       Required if the optional property
>>> "qcom,no-external-phy"
>>> +                       is not specified.
>>
>>
>> Don't you think you will need to know the specific phy device or other
>> properties of the phy?
>
>
> That, I can't answer.  Aren't all MDIO devices basically the same?  It's
> been a while since I've worked on them.

No. There was some discussion just this week about needing to require
phy devices to have compatible strings.

>>> +Optional properties:
>>> +- qcom,emac-tstamp-en       : Enables the PTP (1588) timestamping
>>> feature.
>>> +                             Include this only if PTP (1588)
>>> timestamping
>>> +                             feature is needed. If included, "ptp"
>>> register
>>> +                             base should be specified.
>>
>>
>> Isn't this a user enabled feature if the h/w supports it?
>
>
> Is there a sysfs entry for that?  We were planning on having a similar ACPI
> property.

It would be in ethtool I think.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
