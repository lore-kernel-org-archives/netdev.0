From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH v2 1/2] Documentation: add Device tree bindings for Hisilicon
 hix5hd2 ethernet
Date: Wed, 28 May 2014 13:41:40 +0800
Message-ID: <53857714.3070603@linaro.org>
References: <1401194667-14445-1-git-send-email-zhangfei.gao@linaro.org> <1401194667-14445-2-git-send-email-zhangfei.gao@linaro.org> <20140527133423.GB6969@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"haifeng.yan@linaro.org" <haifeng.yan@linaro.org>,
	"jchxue@gmail.com" <jchxue@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:40524 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbaE1Flw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 01:41:52 -0400
Received: by mail-pa0-f48.google.com with SMTP id rd3so10417109pab.35
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 22:41:52 -0700 (PDT)
In-Reply-To: <20140527133423.GB6969@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Mark

On 05/27/2014 09:34 PM, Mark Rutland wrote:
> On Tue, May 27, 2014 at 01:44:26PM +0100, Zhangfei Gao wrote:
>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
>> ---
>>   .../bindings/net/hisilicon-hix5hd2-gmac.txt        |   36 ++++++++++++++++++++
>>   1 file changed, 36 insertions(+)
>>   create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>> new file mode 100644
>> index 0000000..5fe3835
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>> @@ -0,0 +1,36 @@
>> +Hisilicon hix5hd2 gmac controller
>
> Just to clarify, is the SoC name "hix5hd2", or is the 'x' a wildcard?
"hix5hd2" is Soc name, which contains a series of similar chips.
>
>> +
>> +Required properties:
>> +- compatible: should be "hisilicon,hix5hd2-gmac".
>> +- reg: specifies base physical address(s) and size of the device registers.
>> +  The first region is the MAC register base and size.
>> +  The second region is external interface control register.
>
> Single registers? Are these not part of a larger block?
It is a single register, outside of the memory region.
gmac0: reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
gmac1: reg = <0xf9841000 0x1000>,<0xf9843010 0x4>;

The register is controlling interface mode, duplex etc.
In fact it is rather a bug fix to the silicon, when it is added with 
intension of not touching the original ip design.

It may be moved to the memory region in the future silicon design.
However, currently without such register, it can not work.

>
>> +- interrupts: should contain the MAC interrupts
>
> How many, in which order?
There is only one interrrupt.
How about:
- interrupts: interrupt for the device

>
>> +- #address-cells: must be <1>.
>> +- #size-cells: must be <0>.
>> +- phy-mode: see ethernet.txt [1].
>> +- phy-handle: see ethernet.txt [1].
>> +- mac-address: see ethernet.txt [1].
>> +- clocks: clock phandle and specifier pair.
>
> Is this the only clock input to the gmac block?
>
> Is the clock input named in any documentation?

We have abstract only ONE mac clock input, which is in other patch for 
drivers/clk/hisilicon/clk-hix5hd2.c
The clock input name is in include/dt-bindings/clock/hix5hd2-clock.h, 
described in "Documentation/devicetree/bindings/clock/hix5hd2-clock.txt"

How about:
- clocks: a pointer to the reference clock for this device.

Or should I mention hix5hd2-clock.h in this binding?

>
> Cheers,
> Mark.
>
>> +
>> +- PHY subnode: inherits from phy binding [2]
>> +
>> +[1] Documentation/devicetree/bindings/net/ethernet.txt
>> +[2] Documentation/devicetree/bindings/net/phy.txt
>> +
>> +Example:
>> +	gmac0: ethernet@f9840000 {
>> +		compatible = "hisilicon,hix5hd2-gmac";
>> +		reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
>> +		interrupts = <0 71 4>;
>> +		#address-cells = <1>;
>> +		#size-cells = <0>;
>> +		phy-mode = "mii";
>> +		phy-handle = <&phy2>;
>> +		mac-address = [00 00 00 00 00 00];
>> +		clocks = <&clock HIX5HD2_MAC0_CLK>;
>> +
>> +		phy2: ethernet-phy@2 {
>> +			reg = <2>;
>> +		};
>> +	};
>> --
>> 1.7.9.5
>>
>>
