From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: am335x: cpsw: phy ignores max-speed setting
Date: Fri, 7 Nov 2014 17:27:23 +0100
Message-ID: <CAGm1_kuDsWHxnwEm=odgafSHvf_9KoxUCLN4++C0UW8zGft+4Q@mail.gmail.com>
References: <CAGm1_ktWK5ai85PZJTkq8Q1mAFH6JZ5XM1mDOHO3K_N2iGNLWg@mail.gmail.com>
 <545BA8A2.3010506@gmail.com> <CAGm1_ktReQ5aOJGbvyEB3xQDanCnj_XkwUEWLtB=+sMseZX_pA@mail.gmail.com>
 <545CEF35.9080405@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, mpa@pengutronix.de,
	lsorense@csclub.uwaterloo.ca, Daniel Mack <zonque@gmail.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:44927 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbaKGQ1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 11:27:44 -0500
Received: by mail-pd0-f174.google.com with SMTP id p10so3572454pdj.19
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 08:27:43 -0800 (PST)
In-Reply-To: <545CEF35.9080405@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 7, 2014 at 5:11 PM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
> On Friday 07 November 2014 12:41 PM, Yegor Yefremov wrote:
>> On Thu, Nov 6, 2014 at 5:58 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> On 11/06/2014 08:25 AM, Yegor Yefremov wrote:
>>>> I' m trying to override max-speed setting for both CPSW connected
>>>> PHYs. This is my DTS section for configuring CPSW:
>>>>
>>>> &mac {
>>>>         pinctrl-names = "default", "sleep";
>>>>         pinctrl-0 = <&cpsw_default>;
>>>>         pinctrl-1 = <&cpsw_sleep>;
>>>>         dual_emac = <1>;
>>>>
>>>>         status = "okay";
>>>> };
>>>>
>>>> &davinci_mdio {
>>>>         pinctrl-names = "default", "sleep";
>>>>         pinctrl-0 = <&davinci_mdio_default>;
>>>>         pinctrl-1 = <&davinci_mdio_sleep>;
>>>>
>>>>         status = "okay";
>>>> };
>>>>
>>>> &cpsw_emac0 {
>>>>         phy_id = <&davinci_mdio>, <0>;
>>>>         phy-mode = "rgmii-id";
>>>>         dual_emac_res_vlan = <1>;
>>>>         max-speed = <100>;
>>>> };
>>>>
>>>> &cpsw_emac1 {
>>>>         phy_id = <&davinci_mdio>, <1>;
>>>>         phy-mode = "rgmii-id";
>>>>         dual_emac_res_vlan = <2>;
>>>>         max-speed = <100>;
>>>> };
>>>>
>>>> But in drivers/net/phy/phy_device.c->of_set_phy_supported() routine I
>>>> don't get through node check, i.e. node == NULL. Any idea why?
>>>
>>> Yes, because the 'max-speed' property is placed at the Ethernet MAC node
>>> level, not the PHY node as of_set_phy_supported() expect its.
>>>
>>> This driver does not appear to use the standard Ethernet PHY device tree
>>> node, so I am not sure what are your options here.
>>
>> The SoC has a complex structure, i.e. Ethernet controller has a switch
>> inside with two slaves.
>>
>> A workaround would be perhaps to handle this option in cpsw driver.
>>
>> Mugunthan, what do you think about this?
>
> Yes, CPSW is different from what linux networking is designed for, it
> has two ethernet slave and acts as a Layer 2 switch.
>
> * If you need on a run time basis you can change the supported speed via
> ethtool advertise interface
> * If needed on boot for nfs then need to think of how it can be achieved
> in cpsw driver. Will have a look and update this thread.

ethtool is working, but requires a custom script, so DTS solution
would suite better.

Thanks.

Yegor
