From: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] ARM: at91/net: add macb ethernet controller in 9g45 DT
Date: Mon, 05 Dec 2011 12:39:46 +0100
Message-ID: <4EDCAD82.5050006@atmel.com>
References: <1322847782-22650-1-git-send-email-nicolas.ferre@atmel.com>
 <1322848237-23154-1-git-send-email-nicolas.ferre@atmel.com>
 <20111203055659.GL18533@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20111203055659.GL18533-RQcB7r2h9QmfDR2tN2SG5Ni2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/03/2011 06:56 AM, Jean-Christophe PLAGNIOL-VILLARD :
> On 18:50 Fri 02 Dec     , Nicolas Ferre wrote:
>> Add the Cadence macb ethernet controller in at91sam9g45 .dtsi and
>> enable it in at91sam9m10g45ek board device tree file.
>>
>> Signed-off-by: Nicolas Ferre<nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
>> ---
>>   arch/arm/boot/dts/at91sam9g45.dtsi     |    7 +++++++
>>   arch/arm/boot/dts/at91sam9m10g45ek.dts |    6 ++++++
>>   2 files changed, 13 insertions(+), 0 deletions(-)
>>
>> diff --git a/arch/arm/boot/dts/at91sam9g45.dtsi b/arch/arm/boot/dts/at91sam9g45.dtsi
>> index e89b1d7..67f94d3 100644
>> --- a/arch/arm/boot/dts/at91sam9g45.dtsi
>> +++ b/arch/arm/boot/dts/at91sam9g45.dtsi
>> @@ -101,6 +101,13 @@
>>   				atmel,use-dma-tx;
>>   				status = "disabled";
>>   			};
>> +
>> +			macb0: ethernet@fffbc000 {
>> +				compatible = "cdns,at32ap7000-macb", "cdns,macb";
>> +				reg =<0xfffbc000 0x100>;
>> +				interrupts =<25 4>;
> why?

It is the new AIC specification that was reworked in this patch:
https://lkml.org/lkml/2011/12/1/238

>> +				status = "disabled";
>> +			};
>>   		};
>>   	};
>>   };
>> diff --git a/arch/arm/boot/dts/at91sam9m10g45ek.dts b/arch/arm/boot/dts/at91sam9m10g45ek.dts
>> index 85b34f5..17377a2 100644
>> --- a/arch/arm/boot/dts/at91sam9m10g45ek.dts
>> +++ b/arch/arm/boot/dts/at91sam9m10g45ek.dts
>> @@ -30,6 +30,12 @@
>>   			usart1: serial@fff90000 {
>>   				status = "okay";
>>   			};
>> +
>> +			macb0: ethernet@fffbc000 {
>> +				local-mac-address = [3a 0e 03 04 05 06];
> please drop this is not supposed to be in the dts but updated for each board

Yes, sure: I kept in because it was allowing me to test. But for sure, 
this should go away...

Bye,
-- 
Nicolas Ferre
