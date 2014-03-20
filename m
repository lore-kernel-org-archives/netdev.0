From: Zhangfei Gao <zhangfei.gao@gmail.com>
Subject: Re: [PATCH 1/3] Documentation: add Device tree bindings for Hisilicon
 hip04 ethernet
Date: Thu, 20 Mar 2014 19:29:28 +0800
Message-ID: <CAMj5Bki27+uO9tafp1fF7K8vfE8=F-01zRdU7BAtmF7-D7H0XA@mail.gmail.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
	<1395132017-15928-2-git-send-email-zhangfei.gao@linaro.org>
	<CAGVrzcZY4Z6kFRUP54PtaZUAX0+cEmYfnunJQFN8TC66xooLeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:43633 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755261AbaCTL3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 07:29:30 -0400
In-Reply-To: <CAGVrzcZY4Z6kFRUP54PtaZUAX0+cEmYfnunJQFN8TC66xooLeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian

On Wed, Mar 19, 2014 at 1:39 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014-03-18 1:40 GMT-07:00 Zhangfei Gao <zhangfei.gao@linaro.org>:

>> +Example:
>> +       mdio {
>> +               compatible = "hisilicon,hip04-mdio";
>> +               reg = <0x28f1000 0x1000>;
>> +               #address-cells = <1>;
>> +               #size-cells = <0>;
>> +
>> +               phy0: ethernet-phy@0 {
>> +                       reg = <0>;
>> +                       marvell,reg-init = <18 0x14 0 0x8001>;
>> +                       device_type = "ethernet-phy";
>
> You are missing a compatible string such as
> "ethernet-phy-ieee802.3-c22", please take a look at
> Documentation/devicetree/bindings/net/phy.txt for an example.
>
> device_type is deprecated and should be removed.

Thanks for the info, will update.

>
>> +               };
>> +
>> +               phy1: ethernet-phy@1 {
>> +                       reg = <1>;
>> +                       marvell,reg-init = <18 0x14 0 0x8001>;
>> +                       device_type = "ethernet-phy";
>> +               };
>> +       };
>> +
>> +       ppebase: ppebase@28c0000 {
>> +               compatible = "hisilicon,hip04-ppebase";
>> +               reg = <0x28c0000 0x10000>;
>
> This should probably look like:
>
>                     #address-cells = <0>;
>                     #size-cells = <0>;
>
>                     eth0_port: port@0 {
>                          reg = <0>;
>                     };
>
>                     eth1_port: port@1f {
>                          reg = <31>;
>                     };
>
> This looks like something similar to mv643xx_eth, you should see
> Documentation/devicetree/bindings/marvell.txt for hints on how to
> model the representation in a similar fashion.

Perfect, this looks more professional, just like the phy description.

The ppe is common device with 2048 channels shared by all the
controllers, only if channels are not overlapped.
Two inputs required,
One is port number, currently use reg=<>,
The other is start channel, I used id before.
Each controller use start channel as RX_DESC_NUM * priv->id.
Do you think still use id from of_alias_get_id(), or add another
property like start_chan etc.
                        eth0_port: port@1f {
                                reg = <31>;
                                start-chan = <0>;
                        };

                        eth1_port: port@0 {
                                reg = <0>;
                                start-chan = <1>;
                        };

>
>> +       };
>> +
>> +       fe: ethernet@28b0000 {
>> +               compatible = "hisilicon,hip04-mac";
>> +               reg = <0x28b0000 0x10000>;
>> +               interrupts = <0 413 4>;
>> +               port = <31>;
>
> I do not think this is the right way to expose that, port should be
> specialized to e.g: hisilicon,port, or you should use a phandle to the
> "ppebase" node which exposes differents ports as subnodes:
>
>                     hisilicon,port-handle = <&eth0_port>;
OK, perfect.

>
>> +               speed = <100>;
>
> max-speed is the standard property for this
The speed can be removed now, and the info can be get from phy-mode = "sgmii"

>
>> +               id = <0>;
>
> id here is a software concept, either you create properly numbered
> aliases for these nodes, and use of_alias_get_id(), or you do not use
> these identifiers at all.

Still not not sure whether use of_alias_get_id() or add property in
the eth_port subnode.
The id is used for specify the start channel.

Thanks
