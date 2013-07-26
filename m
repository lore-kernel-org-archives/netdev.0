From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: Re: [PATCH] net: Add MOXA ART SoCs ethernet driver
Date: Fri, 26 Jul 2013 15:12:01 +0200
Message-ID: <CACmBeS0Q_WNc17VSALyMPPKzN1wyLUccBLDJpbapVwxq4gdytQ@mail.gmail.com>
References: <1374140806-12485-1-git-send-email-jonas.jensen@gmail.com>
	<CAGVrzcYdisg5AXMBa5q74GPz7ckWeoXJ9H5di2CGN41VyZ_4vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>, linux-doc@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	arm@kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcYdisg5AXMBa5q74GPz7ckWeoXJ9H5di2CGN41VyZ_4vw@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Thanks for your help on IRC with this. I think most of the issues you
pointed out should be fixed. Comments on still unresolved below:

On 22 July 2013 13:09, Florian Fainelli <florian@openwrt.org> wrote:
>> +++ b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
>> @@ -0,0 +1,25 @@
>> +MOXA ART Ethernet Controller
>> +
>> +Required properties:
>> +
>> +- compatible : Should be "moxa,moxart-mac"
>> +- reg : Should contain registers location and length
>> +  index 0 : main register
>> +  index 1 : mac address (stored on flash)
>
> That is kind of unusual, since the MAC register is within the range of
> the MAC base register, just read the MAC from the base register and
> use that to fill in dev->dev_addr in your ndo_open() callback.

It is, but MAC is zeroed out in controller register after boot. That's why it
has to be read from flash memory (bootloader section), and the reason
it needs to map flash memory at all.

>> +
>> +       res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
>> +
>> +       /* the flash driver (physmap_of) requests the same region
>> +        * so use ioremap instead of devm_ioremap_resource
>> +        */
>> +       priv->flash_base = ioremap(res->start, resource_size(res));
>> +       if (IS_ERR(priv->flash_base)) {
>> +               dev_err(p_dev, "%s: devm_ioremap_resource res_flash failed\n",
>> +                       __func__);
>> +               goto init_fail;
>> +       }
>
> As stated above from the Device Tree binding documentation, this is
> unnecessary, since you have a get_mac() function.

This is what the node looks like right now:

mac0: mac@90900000 {
compatible = "moxa,moxart-mac";
reg = <0x90900000 0x100>,
        <0x80000050 0x6>;
interrupts = <25 0>;
};

Bootloader starts at 0x80000000, looks like MAC is stored in code. I
currently see no way around mapping both registers.

Best regards,
Jonas
