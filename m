From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH v2 2/4] Documentation: dts: Add bindings for APM X-Gene
 SoC ethernet driver
Date: Mon, 14 Apr 2014 15:11:36 -0700
Message-ID: <CAKh23Fk3f=aKq-dvB-bpMFdKFQVP06pkXa1DLzgVErJDAOGPoQ@mail.gmail.com>
References: <1397271984-23405-1-git-send-email-isubramanian@apm.com>
	<1397271984-23405-3-git-send-email-isubramanian@apm.com>
	<CAGVrzcbFHbZBaN1GsxViHaWsttU==2+9cf5mNRGwj9nbNxesVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	patches <patches-qTEPVZfXA3Y@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGVrzcbFHbZBaN1GsxViHaWsttU==2+9cf5mNRGwj9nbNxesVA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Thanks for the review comments.  Please find my responses inline.

On Sat, Apr 12, 2014 at 11:55 AM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 2014-04-11 20:06 GMT-07:00 Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>:
>> This patch adds documentation for APM X-Gene SoC ethernet DTS binding.
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
>> Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
>> Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
>> ---
>>  .../devicetree/bindings/net/apm-xgene-enet.txt     |   46 ++++++++++++++++++++
>>  1 file changed, 46 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-enet.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
>> new file mode 100644
>> index 0000000..0c983e8
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
>> @@ -0,0 +1,46 @@
>> +APM X-Gene SoC Ethernet nodes
>> +
>> +Ethernet nodes are defined to describe on-chip ethernet interfaces in
>> +APM X-Gene SoC.
>> +
>> +Required properties:
>> +- compatible           : Should be "apm,xgene-enet"
>> +- reg                  : First resource is the ethernet base register set
>> +                         Second resource is the ring base register set
>> +                         Third resource is the ring command register set
>> +- interrupts           : Ethernet main interrupt
>> +- clocks               : Reference to the clock entry.
>> +- local-mac-address    : Ethernet MAC address.
>> +- phy-addr             : Ethernet MII phy address.
>> +- phy-mode             : Ethernet MII mode.
>> +
>> +Optional properties:
>> +- status               : Should be "ok" or "disabled" for enabled/disabled.
>> +                         Default is "ok".
>> +
>> +Example:
>> +       menetclk: menetclk {
>> +               compatible = "apm,xgene-device-clock";
>> +               clock-output-names = "menetclk";
>> +               status = "ok";
>> +       };
>> +
>> +       menet: ethernet@17020000 {
>> +               compatible = "apm,xgene-enet";
>> +               status = "disabled";
>> +               reg = <0x0 0x17020000 0x0 0xd100>,
>> +                     <0x0 0X17030000 0x0 0X400>,
>> +                     <0x0 0X10000000 0x0 0X200>;
>> +               interrupts = <0x0 0x3c 0x4>;
>> +               clocks = <&menetclk 0>;
>> +               local-mac-address = [00 01 73 00 00 01];
>> +               phy-addr = <3>;
>
> An Ethernet PHY node needs to follow the ePAPR recommended
> representation, which is not this one. Please refer to
> Documentation/devicetree/bindinsg/net/phy.txt for examples on how to
> do this properly.

Okay.  I will change the dts to use phy-handle property and remove
phy-addr.

>
>> +               phy-mode = "rgmii";
>> +       };
>> +
>> +
>> +/* Board-specific peripheral configurations */
>> +
>> +&menet {
>> +        status = "ok";
>> +};
>> --
>> 1.7.9.5
>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>
>
>
> --
> Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
