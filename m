From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH 2/5] arm64: dts: APM X-Gene SoC Ethernet device tree nodes
Date: Fri, 11 Apr 2014 13:03:06 -0700
Message-ID: <CAKh23FmGYGkCbeh4DbL4_NO6ypkw4F70J0X__KxFyHTo-=WtKg@mail.gmail.com>
References: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
	<1387597376-29303-3-git-send-email-isubramanian@apm.com>
	<1390582906.12454.26.camel@deneb.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, Greg KH <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	"jcm@redhat.com" <jcm@redhat.com>, patches <patches@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: Mark Salter <msalter@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390582906.12454.26.camel@deneb.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mark,

Thanks for the review comment and I apologize for not replying sooner.

We are completely redesigning the ethernet driver to make it simple
and cleaner and will be posted shortly.

Please find my response by searching for isubrama:

Thanks,
Iyappan

On Fri, Jan 24, 2014 at 9:01 AM, Mark Salter <msalter@redhat.com> wrote:
> On Fri, 2013-12-20 at 19:42 -0800, Iyappan Subramanian wrote:
>> Device tree files for APM X-Gene SoC Ethernet.
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>> Signed-off-by: Ravi Patel <rapatel@apm.com>
>> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
>> ---
>>  arch/arm64/boot/dts/apm-mustang.dts |    8 ++++++++
>>  arch/arm64/boot/dts/apm-storm.dtsi  |   19 +++++++++++++++++++
>>  2 files changed, 27 insertions(+)
>>
>> diff --git a/arch/arm64/boot/dts/apm-mustang.dts b/arch/arm64/boot/dts/apm-mustang.dts
>> index 1247ca1..ccb2771 100644
>> --- a/arch/arm64/boot/dts/apm-mustang.dts
>> +++ b/arch/arm64/boot/dts/apm-mustang.dts
>> @@ -17,6 +17,10 @@
>>       model = "APM X-Gene Mustang board";
>>       compatible = "apm,mustang", "apm,xgene-storm";
>>
>> +        aliases {
>> +                ethernet0 = &menet;
>> +        };
>> +
>>       chosen { };
>>
>>       memory {
>> @@ -24,3 +28,7 @@
>>               reg = < 0x1 0x00000000 0x0 0x80000000 >; /* Updated by bootloader */
>>       };
>>  };
>> +
>> +&menet {
>> +        status = "ok";
>> +};
>> diff --git a/arch/arm64/boot/dts/apm-storm.dtsi b/arch/arm64/boot/dts/apm-storm.dtsi
>> index f64f946..9c7b8cd 100644
>> --- a/arch/arm64/boot/dts/apm-storm.dtsi
>> +++ b/arch/arm64/boot/dts/apm-storm.dtsi
>> @@ -204,5 +204,24 @@
>>                       #clock-cells = <1>;
>>                       clocks = <&qmlclk 0>;
>>               };
>> +
>> +             menet: ethernet@17020000 {
>> +                     compatible = "apm,xgene-enet";
>> +                     status = "disabled";
>> +                     reg = <0x0 0x17020000 0x0 0x30>,
>> +                           <0x0 0x17020000 0x0 0x10000>,
>> +                           <0x0 0x17020000 0x0 0x20>;
>> +                     slave-name = "RGMII";
>> +                     interrupts = <0x0 0x38 0x4>,
>> +                                  <0x0 0x39 0x4>,
>> +                                  <0x0 0x3a 0x4>;
>> +                     #clock-cells = <1>;
>> +                     clocks = <&eth8clk 0>;
>> +                     local-mac-address = <0x0 0x11 0x3a 0x8a 0x5a 0x78>;
>
> Shouldn't this be a byte string?:
isubrama:
Agree.  I changed the driver.
>
>                         local-mac-address = [ 00 11 3a 8a 5a 78 ];
>
>> +                     max-frame-size = <0x233a>;
>> +                     devid = <8>;
>> +                     phyid = <3>;
>> +                     phy-mode = "rgmii";
>> +             };
>>       };
>>  };
>
>
