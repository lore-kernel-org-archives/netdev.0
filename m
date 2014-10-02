From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v1 3/5] dtb: Add 10GbE node to APM X-Gene SoC device tree
Date: Thu, 2 Oct 2014 16:24:11 -0700
Message-ID: <CAKh23FmgajO96c7JeyT4baU1Q23sTW2NWwGezgAjGKodqzjYWQ@mail.gmail.com>
References: <1411530688-2939-1-git-send-email-isubramanian@apm.com>
	<1411530688-2939-4-git-send-email-isubramanian@apm.com>
	<20140924093727.GA9162@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"kchudgar@apm.com" <kchudgar@apm.com>,
	"patches@apm.com" <patches@apm.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og124.obsmtp.com ([64.18.0.212]:55685 "HELO
	exprod5og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752910AbaJBXYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 19:24:13 -0400
Received: by mail-lb0-f180.google.com with SMTP id f15so98871lbj.39
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 16:24:11 -0700 (PDT)
In-Reply-To: <20140924093727.GA9162@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 2:37 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> Hi,
>
> For some reason, the below appears to use a mixture of spaces and tabs
> for alignment. Assuming my local mailserver isn't responsible for that,
> could you please correct that and for consistency use tabs?
>
> Could you also please Cc the arm64 maintainers when submitting arm64
> patches?
>
> On Wed, Sep 24, 2014 at 04:51:26AM +0100, Iyappan Subramanian wrote:
>> Added 10GbE interface and clock nodes.
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>> ---
>>  arch/arm64/boot/dts/apm-mustang.dts |  4 ++++
>>  arch/arm64/boot/dts/apm-storm.dtsi  | 24 ++++++++++++++++++++++++
>>  2 files changed, 28 insertions(+)
>>
>> diff --git a/arch/arm64/boot/dts/apm-mustang.dts b/arch/arm64/boot/dts/apm-mustang.dts
>> index b2f5622..2ae782b 100644
>> --- a/arch/arm64/boot/dts/apm-mustang.dts
>> +++ b/arch/arm64/boot/dts/apm-mustang.dts
>> @@ -32,3 +32,7 @@
>>  &menet {
>>       status = "ok";
>>  };
>> +
>> +&xgenet {
>> +     status = "ok";
>> +};
>> diff --git a/arch/arm64/boot/dts/apm-storm.dtsi b/arch/arm64/boot/dts/apm-storm.dtsi
>> index c0aceef..ae814ef 100644
>> --- a/arch/arm64/boot/dts/apm-storm.dtsi
>> +++ b/arch/arm64/boot/dts/apm-storm.dtsi
>> @@ -176,6 +176,16 @@
>>                               clock-output-names = "menetclk";
>>                       };
>>
>> +                        xge0clk: xge0clk@1f61c000 {
>> +                             compatible = "apm,xgene-device-clock";
>> +                             #clock-cells = <1>;
>> +                             clocks = <&socplldiv2 0>;
>> +                             reg = <0x0 0x1f61c000 0x0 0x1000>;
>> +                             reg-names = "csr-reg";
>> +                             csr-mask = <0x3>;
>> +                             clock-output-names = "xge0clk";
>> +                        };
>> +
>>                       sataphy1clk: sataphy1clk@1f21c000 {
>>                               compatible = "apm,xgene-device-clock";
>>                               #clock-cells = <1>;
>> @@ -421,5 +431,19 @@
>>
>>                       };
>>               };
>> +
>> +                xgenet: ethernet@1f610000 {
>> +                     compatible = "apm,xgene-enet";
>> +                        status = "disabled";
>> +                        reg = <0x0 0x1f610000 0x0 0xd100>,
>> +                              <0x0 0x1f600000 0x0 0X400>,
>> +                              <0x0 0x18000000 0x0 0X200>;
>> +                     reg-names = "enet_csr", "ring_csr", "ring_cmd";
>> +                        interrupts = <0x0 0x60 0x4>;
>> +                     dma-coherent;
>> +                        clocks = <&xge0clk 0>;
>
>> +                        local-mac-address = [00 01 73 00 00 04];
>
> Does it really make sense to hard-code the same mac address for all
> mustang boards?

I tried to keep the OUI for the first 3 bytes.  APM OUI = 00 01 73.
I noticed some other vendors dtbs have all 0's.  Since they will get
overwritten by the bootloader, please suggest the preferred way.

>
> Mark.
>
>> +                     phy-connection-type = "xgmii";
>> +                };
>>       };
>>  };
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe devicetree" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
