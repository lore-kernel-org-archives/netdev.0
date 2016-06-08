From: Ivan Khoronzhuk <ivan.khoronzhuk-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 0/2] net: ethernet: ti: cpsw: delete rx_descs property
Date: Wed, 8 Jun 2016 17:01:25 +0300
Message-ID: <57582535.5020608@linaro.org>
References: <1465307976-12235-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <5756E7A8.6090703@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: grygorii.strashko-l0cyMroinI0@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Schuyler Patton <spatton-l0cyMroinI0@public.gmane.org>, mugunthanvnm-l0cyMroinI0@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5756E7A8.6090703-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Schuyer,

On 07.06.16 18:26, Schuyler Patton wrote:
> Hi,
>
> On 06/07/2016 08:59 AM, Ivan Khoronzhuk wrote:
>> There is no reason in rx_descs property because davinici_cpdma
>> driver splits pool of descriptors equally between tx and rx channels.
>> So, this patch series makes driver to use available number of
>> descriptors for rx channels.
>
> I agree with the idea of consolidating how the descriptors are defined because of
> the two variable components, number and size of the pool can be confusing to
> end users. I would like to request to change how it is being proposed here.
>
> I think the number of descriptors should be left in the device tree source file as
> is and remove the BD size variable and have the driver calculate the size of the
> pool necessary to support the descriptor request. From an user perspective it is
> easier I think to be able to list the number of descriptors necessary vs. the size
> of the pool.
>
> Since the patch series points out how it is used so in the driver so to make that
> consistent is perhaps change rx_descs to total_descs.
>
> Regards,
> Schuyler

The DT entry for cpsw doesn't have property for size of the pool.
It contains only BD ram size, if you mean this. The size of the pool is
software decision. Current version of DT entry contain only rx desc number.
That is not correct, as it depends on the size of the descriptor, which is also
h/w parameter. The DT entry has to describe only h/w part and shouldn't contain
driver implementation details, and I'm looking on it from this perspective.

Besides, rx_descs describes only rx number of descriptors, that are taken from
the same pool as tx descriptors, and setting rx desc to some new value doesn't
mean that rest of them are freed for tx. Also, I'm going to send series that
adds multi channel support to the driver, and in this case, splitting of the
pool will be more sophisticated than now, after what setting those parameters
for user (he should do this via device tree) can be even more confusing. But,
as it's supposed, it's software decision that shouldn't leak to the DT.


>>
>> Based on master branch
>>
>> Since v1:
>> - separate device tree and driver patches
>> - return number of rx buffers from cpdma driver
>>
>> Ivan Khoronzhuk (2):
>>    net: ethernet: ti: cpsw: remove rx_descs property
>>    Documentation: DT: cpsw: remove rx_descs property
>>
>>   Documentation/devicetree/bindings/net/cpsw.txt |  1 -
>>   arch/arm/boot/dts/am33xx.dtsi                  |  1 -
>>   arch/arm/boot/dts/am4372.dtsi                  |  1 -
>>   arch/arm/boot/dts/dm814x.dtsi                  |  1 -
>>   arch/arm/boot/dts/dra7.dtsi                    |  1 -
>>   drivers/net/ethernet/ti/cpsw.c                 | 13 +++----------
>>   drivers/net/ethernet/ti/cpsw.h                 |  1 -
>>   drivers/net/ethernet/ti/davinci_cpdma.c        |  6 ++++++
>>   drivers/net/ethernet/ti/davinci_cpdma.h        |  1 +
>>   9 files changed, 10 insertions(+), 16 deletions(-)
>>
>

-- 
Regards,
Ivan Khoronzhuk
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
