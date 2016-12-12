From: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: Re: [PATCH v2 1/4] net: hix5hd2_gmac: add generic compatible string
Date: Mon, 12 Dec 2016 19:16:45 +0800
Message-ID: <584E871D.7060200@hisilicon.com>
References: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
 <1480944481-118803-2-git-send-email-lidongpo@hisilicon.com>
 <20161209223521.5dnj7l44e663sntl@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <mark.rutland-5wv7dgnIgG8@public.gmane.org>, <mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
        <andrew-g2DYL2Zd6BY@public.gmane.org>, <xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
        <benjamin.chenhao-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <caizhiyong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161209223521.5dnj7l44e663sntl@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,

On 2016/12/10 6:35, Rob Herring wrote:
> On Mon, Dec 05, 2016 at 09:27:58PM +0800, Dongpo Li wrote:
>> The "hix5hd2" is SoC name, add the generic ethernet driver name.
>> The "hisi-gemac-v1" is the basic version and "hisi-gemac-v2" adds
>> the SG/TXCSUM/TSO/UFO features.
>>
>> Signed-off-by: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
>> ---
>>  .../devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt    |  9 +++++++--
>>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c             | 15 +++++++++++----
>>  2 files changed, 18 insertions(+), 6 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>> index 75d398b..75920f0 100644
>> --- a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>> @@ -1,7 +1,12 @@
>>  Hisilicon hix5hd2 gmac controller
>>  
>>  Required properties:
>> -- compatible: should be "hisilicon,hix5hd2-gmac".
>> +- compatible: should contain one of the following SoC strings:
>> +	* "hisilicon,hix5hd2-gemac"
>> +	* "hisilicon,hi3798cv200-gemac"
>> +	and one of the following version string:
>> +	* "hisilicon,hisi-gemac-v1"
>> +	* "hisilicon,hisi-gemac-v2"
> 
> What combinations are valid? I assume both chips don't have both v1 and 
> v2. 2 SoCs and 2 versions so far, I don't think there is much point to 
> have the v1 and v2 compatible strings.
> 
The v1 and v2 are generic MAC compatible strings, many HiSilicon SoCs may
use the same MAC version. For example,
hix5hd2, hi3716cv200 SoCs use the v1 MAC version,
hi3798cv200, hi3516a SoCs use the v2 MAC version,
and there may be more SoCs added in future.
So I think the generic compatible strings are okay here.
Should I add the hi3716cv200, hi3516a SoCs compatible here?
Do you have any good advice?

>>  - reg: specifies base physical address(s) and size of the device registers.
>>    The first region is the MAC register base and size.
>>    The second region is external interface control register.
>> @@ -20,7 +25,7 @@ Required properties:
>>  
>>  Example:
>>  	gmac0: ethernet@f9840000 {
>> -		compatible = "hisilicon,hix5hd2-gmac";
>> +		compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
> 
> You can't just change compatible strings.
> 
Okay, maybe I should name all the compatible string with the suffix "-gmac" instead of
"-gemac". This can keep the compatible strings with the same suffix. Is this okay?
Can I just add the generic compatible string without changing the SoCs compatible string?
Like following:
  	gmac0: ethernet@f9840000 {
 -		compatible = "hisilicon,hix5hd2-gmac";
 +		compatible = "hisilicon,hix5hd2-gmac", "hisilicon,hisi-gmac-v1";

>>  		reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
>>  		interrupts = <0 71 4>;
>>  		#address-cells = <1>;
> 
> .
> 


    Regards,
    Dongpo

.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
