From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH v2 2/4] Documentation: dts: Add bindings for APM X-Gene
 SoC ethernet driver
Date: Mon, 14 Apr 2014 15:15:19 -0700
Message-ID: <CAKh23FkRJAqS7+5m+0k1E8gx3T23xsBfq8bw=847MR-uJxZvJQ@mail.gmail.com>
References: <1397271984-23405-1-git-send-email-isubramanian@apm.com>
	<1397271984-23405-3-git-send-email-isubramanian@apm.com>
	<534BDD6F.2070903@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, patches <patches-qTEPVZfXA3Y@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Ben Dooks <ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <534BDD6F.2070903-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Ben,

Thanks for the review comments. Please find my responses inline.

Thanks,
Iyappan

On Mon, Apr 14, 2014 at 6:06 AM, Ben Dooks <ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org> wrote:
> On 12/04/14 04:06, Iyappan Subramanian wrote:
>>
>> This patch adds documentation for APM X-Gene SoC ethernet DTS binding.
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
>> Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
>> Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
>> ---
>>   .../devicetree/bindings/net/apm-xgene-enet.txt     |   46
>> ++++++++++++++++++++
>>   1 file changed, 46 insertions(+)
>>   create mode 100644
>> Documentation/devicetree/bindings/net/apm-xgene-enet.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
>> b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
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
>> +- status               : Should be "ok" or "disabled" for
>> enabled/disabled.
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
>> +               phy-mode = "rgmii";
>> +       };
>
>
> That doesn't look correct for a phy binding.
>

Okay.  I will change the dts to use phy-handle property and remove
phy-addr.  I will also rename phy-mode to phy-connection-type as per
Documentation/devicetree/bindings/net/ethernet.txt

>
> --
> Ben Dooks                               http://www.codethink.co.uk/
> Senior Engineer                         Codethink - Providing Genius
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
