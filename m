From: PERIER Romain <romain.perier@gmail.com>
Subject: Re: [PATCH 4/4] ARM: dts: Enable emac node on the rk3188-radxarock boards
Date: Wed, 3 Sep 2014 18:37:16 +0200
Message-ID: <CABgxDoJOJ9bM2CgXyXjPvsv2DN_QO+HPAzCwfjdyKFDpUAOtOw@mail.gmail.com>
References: <1409740036-8117-1-git-send-email-romain.perier@gmail.com>
	<1409740036-8117-4-git-send-email-romain.perier@gmail.com>
	<CAFnsNoSmHwN3nJ5ZJL5fc_-kaECCoLBvpdBYQxkyLcUzLx5MTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>,
	linux-rockchip@lists.infradead.org,
	devicetree <devicetree@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	netdev <netdev@vger.kernel.org>
To: Naoki FUKAUMI <naobsd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:51716 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaICQhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 12:37:23 -0400
In-Reply-To: <CAFnsNoSmHwN3nJ5ZJL5fc_-kaECCoLBvpdBYQxkyLcUzLx5MTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is an optional property used by arc-emac (the core driver), if it
is not present the core driver generates one for you.
Problem being that with this property two radxa rock boards connected
on the same local network might have the same mac address.

In this case it would be probably better to remove this property. What
do you think ?

2014-09-03 17:29 GMT+02:00 Naoki FUKAUMI <naobsd@gmail.com>:
> On Wed, Sep 3, 2014 at 7:27 PM, Romain Perier <romain.perier@gmail.com> wrote:
>> This enables EMAC Rockchip support on radxa rock boards.
>>
>> Signed-off-by: Romain Perier <romain.perier@gmail.com>
>> ---
>>  arch/arm/boot/dts/rk3188-radxarock.dts | 24 ++++++++++++++++++++++++
>>  1 file changed, 24 insertions(+)
>>
>> diff --git a/arch/arm/boot/dts/rk3188-radxarock.dts b/arch/arm/boot/dts/rk3188-radxarock.dts
>> index 5e4e3c23..e1358d3 100644
>> --- a/arch/arm/boot/dts/rk3188-radxarock.dts
>> +++ b/arch/arm/boot/dts/rk3188-radxarock.dts
>> @@ -76,6 +76,24 @@
>>         };
>>  };
>>
>> +&emac {
>> +       status = "okay";
>> +       compatible = "rockchip,rk3188-emac";
>> +
>> +       pinctrl-names = "default";
>> +       pinctrl-0 = <&emac_xfer>, <&emac_mdio>, <&phy_int>;
>> +
>> +       mac-address = [ c6 ef 91 8e 60 4b ];
>
> is "mac-address" required?
