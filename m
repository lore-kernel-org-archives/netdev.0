From: "Yankejian (Hackim Yim)" <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] net: hns: enet specisies a reference to dsaf
 (config and documents)
Date: Mon, 7 Dec 2015 15:14:13 +0800
Message-ID: <566531C5.4050208@huawei.com>
References: <1449295856-31068-1-git-send-email-yankejian@huawei.com>
 <1449295856-31068-3-git-send-email-yankejian@huawei.com>
 <23027215.8RIhViTVaB@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <23027215.8RIhViTVaB@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2015/12/6 6:19, Arnd Bergmann wrote:
> On Saturday 05 December 2015 14:10:56 yankejian wrote:
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>> index 80411b2..ecacfa4 100644
>> --- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>> @@ -4,8 +4,6 @@ Required properties:
>>  - compatible: should be "hisilicon,hns-dsaf-v1" or "hisilicon,hns-dsaf-v2".
>>    "hisilicon,hns-dsaf-v1" is for hip05.
>>    "hisilicon,hns-dsaf-v2" is for Hi1610 and Hi1612.
>> -- dsa-name: dsa fabric name who provide this interface.
>> -  should be "dsafX", X is the dsaf id.
>>  - mode: dsa fabric mode string. only support one of dsaf modes like these:
>>                 "2port-64vf",
>>                 "6port-16rss",
>> @@ -26,9 +24,8 @@ Required properties:
>>  
>>  Example:
>>  
>> -dsa: dsa@c7000000 {
>> +dsaf0: dsa@c7000000 {
>>         compatible = "hisilicon,hns-dsaf-v1";
>> -       dsa_name = "dsaf0";
>>         mode = "6port-16rss";
>>         interrupt-parent = <&mbigen_dsa>;
>>         reg = <0x0 0xC0000000 0x0 0x420000
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>> index 41d19be..e6a9d1c 100644
>> --- a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>> @@ -4,8 +4,9 @@ Required properties:
>>  - compatible: "hisilicon,hns-nic-v1" or "hisilicon,hns-nic-v2".
>>    "hisilicon,hns-nic-v1" is for hip05.
>>    "hisilicon,hns-nic-v2" is for Hi1610 and Hi1612.
>> -- ae-name: accelerator name who provides this interface,
>> -  is simply a name referring to the name of name in the accelerator node.
>> +- ae-handle: accelerator engine handle for hns,
>> +  specifies a reference to the associating hardware driver node.
>> +  see Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>>  - port-id: is the index of port provided by DSAF (the accelerator). DSAF can
>>    connect to 8 PHYs. Port 0 to 1 are both used for adminstration purpose. They
>>    are called debug ports.
>> @@ -41,7 +42,7 @@ Example:
>>  
>>
> This looks like an incompatible change, as you add and remove
> required properties. Is there a way to support both the old and
> the new style?
>
> 	Arnd
>
> .

Hi Arnd,
Thanks for your suggestions.  it must be set the same strings in dsaf node and every enet node before.
it seems inappropriate. as Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> 's suggestions, that would solve associating
enet with a particular dsaf. so we discus the solution with Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>.
we decide to use the new way instead of the old one.

Best regards,
yankejian

>


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
