From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: arRe: [PATCH net-next 2/2] net: hns: enet specisies a reference
 to dsaf (config and documents)
Date: Wed, 9 Dec 2015 17:25:13 +0800
Message-ID: <5667F379.2010108@huawei.com>
References: <1449295856-31068-1-git-send-email-yankejian@huawei.com>
 <23027215.8RIhViTVaB@wuerfel> <566531C5.4050208@huawei.com>
 <1503684.BNZUVaD74W@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <fengguang.wu@intel.com>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<salil.mehta@huawei.com>, <Yisen.Zhuang@huawei.com>,
	<liguozhu@huawei.com>, <lisheng011@huawei.com>,
	<huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503684.BNZUVaD74W@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/12/7 17:40, Arnd Bergmann wrote:
> On Monday 07 December 2015 15:14:13 Yankejian wrote:
>> On 2015/12/6 6:19, Arnd Bergmann wrote:
>>> On Saturday 05 December 2015 14:10:56 yankejian wrote:
>>>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>>>> index 80411b2..ecacfa4 100644
>>>> --- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>>>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>>>> @@ -4,8 +4,6 @@ Required properties:
>>>>  - compatible: should be "hisilicon,hns-dsaf-v1" or "hisilicon,hns-dsaf-v2".
>>>>    "hisilicon,hns-dsaf-v1" is for hip05.
>>>>    "hisilicon,hns-dsaf-v2" is for Hi1610 and Hi1612.
>>>> -- dsa-name: dsa fabric name who provide this interface.
>>>> -  should be "dsafX", X is the dsaf id.
>>>>  - mode: dsa fabric mode string. only support one of dsaf modes like these:
>>>>                 "2port-64vf",
>>>>                 "6port-16rss",
>>>> @@ -26,9 +24,8 @@ Required properties:
>>>>  
>>>>  Example:
>>>>  
>>>> -dsa: dsa@c7000000 {
>>>> +dsaf0: dsa@c7000000 {
>>>>         compatible = "hisilicon,hns-dsaf-v1";
>>>> -       dsa_name = "dsaf0";
>>>>         mode = "6port-16rss";
>>>>         interrupt-parent = <&mbigen_dsa>;
>>>>         reg = <0x0 0xC0000000 0x0 0x420000
>>>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>>>> index 41d19be..e6a9d1c 100644
>>>> --- a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>>>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>>>> @@ -4,8 +4,9 @@ Required properties:
>>>>  - compatible: "hisilicon,hns-nic-v1" or "hisilicon,hns-nic-v2".
>>>>    "hisilicon,hns-nic-v1" is for hip05.
>>>>    "hisilicon,hns-nic-v2" is for Hi1610 and Hi1612.
>>>> -- ae-name: accelerator name who provides this interface,
>>>> -  is simply a name referring to the name of name in the accelerator node.
>>>> +- ae-handle: accelerator engine handle for hns,
>>>> +  specifies a reference to the associating hardware driver node.
>>>> +  see Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>>>>  - port-id: is the index of port provided by DSAF (the accelerator). DSAF can
>>>>    connect to 8 PHYs. Port 0 to 1 are both used for adminstration purpose. They
>>>>    are called debug ports.
>>>> @@ -41,7 +42,7 @@ Example:
>>>>  
>>>>
>>> This looks like an incompatible change, as you add and remove
>>> required properties. Is there a way to support both the old and
>>> the new style?
>>>
>>>       Arnd
>>>
>>> .
>> Hi Arnd,
>> Thanks for your suggestions.  it must be set the same strings in dsaf node and every enet node before.
>> it seems inappropriate. as Rob Herring <robh@kernel.org> 's suggestions, that would solve associating
>> enet with a particular dsaf. so we discus the solution with Yisen Zhuang <yisen.zhuang@huawei.com>.
>> we decide to use the new way instead of the old one.
> I agree the new form looks better than the original way, but I'm worried
> about the migration path. You don't explain in the patch description
> how you want to ensure that nothing breaks for existing systems.
>
> We generally try to avoid doing incompatible changes altogether and
> prefer to keep backwards compatibility, unless we can prove that no
> other systems exist that would get impacted by the change.
>
> Are you sure that nobody ships a DTB file for this hardware with their
> firmware that would now require an incompatible update which in turn
> breaks old kernels?
>
> Are you sure that there is no hardware using the same dsa hardware
> with out-of-tree dts files that need to make the same change but might
> not be aware of the change?
>
> 	Arnd
>
> .
 
 hi Arnd.

 thanks a lot for pointing it out.

 It is great regret that this change breaks compatibility with old dtbs.
 this is a new driver which is run on developing boards, and all the
 clients' boards are developing boards. So we provide them a method to
 update the firmware on the board, once we update the dtsi and kernel,
 we require our clients to update the existed firmware and kernel.
 Therefore, these changes is actually under control. Shall we treat this
 by this way?

 thanks very much.
