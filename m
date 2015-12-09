From: "Yankejian (Hackim Yim)" <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 next 1/2] dts: hisi: fixes no syscon error when init
 mdio
Date: Wed, 9 Dec 2015 18:52:12 +0800
Message-ID: <566807DC.8030107@huawei.com>
References: <1449476707-224320-1-git-send-email-yankejian@huawei.com>
 <1449476707-224320-2-git-send-email-yankejian@huawei.com>
 <20151208152514.GA27037@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<wangkefeng.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <haojian.zhuang-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<wangzhou1-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <bintian.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<long.wanglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <leo.yan-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151208152514.GA27037@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2015/12/8 23:25, Rob Herring wrote:
> On Mon, Dec 07, 2015 at 04:25:06PM +0800, yankejian wrote:
>> Signed-nux start up, we get the log below:
>> "Hi-HNS_MDIO 803c0000.mdio: no syscon hisilicon,peri-c-subctrl
>>  mdio_bus mdio@803c0000: mdio sys ctl reg has not maped       "
>>
>> the source code about the subctrl is dealled with syscon, but dts doesn't.
> The source...
>
> s/dealled/dealt/
Thanks for pointing it out. it will be changed in patch v3.
Best Regards,
yankejian

>> it cause such fault. so this patch adds the syscon info on dts files to
>> fixes it. and it adds documentation for the devicetree bindings used by
> Capitalization please.

Thanks a lot for pointing it out. i will pay attention to that next time.
Best Regards,
yankejian
>> DT files of Hisilicon Hip05-D02 development board.
>>
>> Signed-off-by: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> ---
>> change log:
>> v2:
>>  1) updates the related documented in the binding as well
>>  2) use the normal naming conventions using '-' instead of '_'
>>
>> v1:
>>  initial version
>> ---
>>  .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
>>  arch/arm64/boot/dts/hisilicon/hip05.dtsi                 |  5 +++++
>>  arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi             |  4 ++--
>>  3 files changed, 23 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt b/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
>> index 6ac7c00..9f05767 100644
>> --- a/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
>> +++ b/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
>> @@ -187,6 +187,22 @@ Example:
>>  		reg = <0xb0000000 0x10000>;
>>  	};
>>  
>> +Hisilicon HiP05 PERISUB system controller
>> +
>> +Required properties:
>> +- compatible : "hisilicon,peri-c-subctrl", "syscon";
>> +- reg : Register address and size
>> +
>> +The HiP05 PERISUB system controller is shared by peripheral controllers in
>> +HiP05 Soc to implement some basic configurations. the peripheral
>> +controllers include mdio, ddr, iic, uart, timer and so on.
>> +
>> +Example:
>> +	/* for HiP05 PCIe-SAS system */
>> +	peri-c-subctrl: sub-ctrl-c@80000000 {
> s/sub-ctrl-c/syscon/
Thanks for pointing it out. it will be changed in patch v3.
Best Regards,
yankejian
>
>> +		compatible = "hisilicon,peri-c-subctrl", "syscon";
>> +		reg = <0x0 0x80000000 0x0 0x10000>;
>> +	};
>>  -----------------------------------------------------------------------
>>  Hisilicon CPU controller
>>  
>> diff --git a/arch/arm64/boot/dts/hisilicon/hip05.dtsi b/arch/arm64/boot/dts/hisilicon/hip05.dtsi
>> index 4ff16d0..5fec740 100644
>> --- a/arch/arm64/boot/dts/hisilicon/hip05.dtsi
>> +++ b/arch/arm64/boot/dts/hisilicon/hip05.dtsi
>> @@ -246,6 +246,11 @@
>>  			clock-frequency = <200000000>;
>>  		};
>>  
>> +		peri_c_subctrl: sub-ctrl-c@80000000 {
>> +			compatible = "hisilicon,peri-c-subctrl", "syscon";
>> +			reg = < 0x0 0x80000000 0x0 0x10000>;
>> +		};
>> +
>>  		uart0: uart@80300000 {
>>  			compatible = "snps,dw-apb-uart";
>>  			reg = <0x0 0x80300000 0x0 0x10000>;
>> diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
>> index 606dd5a..da7b6e6 100644
>> --- a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
>> +++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
>> @@ -10,8 +10,8 @@ soc0: soc@000000000 {
>>  		#address-cells = <1>;
>>  		#size-cells = <0>;
>>  		compatible = "hisilicon,hns-mdio";
>> -		reg = <0x0 0x803c0000 0x0 0x10000
>> -		       0x0 0x80000000 0x0 0x10000>;
>> +		reg = <0x0 0x803c0000 0x0 0x10000>;
>> +		subctrl-vbase = <&peri_c_subctrl>;
>>  
>>  		soc0_phy0: ethernet-phy@0 {
>>  			reg = <0x0>;
>> -- 
>> 1.9.1
>>
> .
>


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
