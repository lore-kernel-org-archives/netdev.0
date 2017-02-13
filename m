From: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Subject: Re: [PATCH] Make EN2 pin optional in the TRF7970A driver
Date: Mon, 13 Feb 2017 07:38:12 +0100
Message-ID: <58A15454.4030602@denx.de>
References: <1486444924-18444-1-git-send-email-hs@denx.de>
 <20170210155114.pvjahqqjqurw5jdc@rob-hp-laptop>
Reply-To: hs-ynQEQJNshbs@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Ben <ben.guan-dUNdQdTMQaZWk0Htik3J/w@public.gmane.org>,
        Mark Jonas <mark.jonas-V5te9oGctAVWk0Htik3J/w@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170210155114.pvjahqqjqurw5jdc@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Rob,

Am 10.02.2017 um 16:51 schrieb Rob Herring:
> On Tue, Feb 07, 2017 at 06:22:04AM +0100, Heiko Schocher wrote:
>> From: Guan Ben <ben.guan-dUNdQdTMQaZWk0Htik3J/w@public.gmane.org>
>>
>> Make the EN2 pin optional. This is useful for boards,
>> which have this pin fix wired, for example to ground.
>>
>> Signed-off-by: Guan Ben <ben.guan-dUNdQdTMQaZWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Mark Jonas <mark.jonas-V5te9oGctAVWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
>>
>> ---
>>
>>   .../devicetree/bindings/net/nfc/trf7970a.txt       |  4 ++--
>>   drivers/nfc/trf7970a.c                             | 26 ++++++++++++----------
>>   2 files changed, 16 insertions(+), 14 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
>> index 32b35a0..5889a3d 100644
>> --- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
>> +++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
>> @@ -5,8 +5,8 @@ Required properties:
>>   - spi-max-frequency: Maximum SPI frequency (<= 2000000).
>>   - interrupt-parent: phandle of parent interrupt handler.
>>   - interrupts: A single interrupt specifier.
>> -- ti,enable-gpios: Two GPIO entries used for 'EN' and 'EN2' pins on the
>> -  TRF7970A.
>> +- ti,enable-gpios: One or two GPIO entries used for 'EN' and 'EN2' pins on the
>> +  TRF7970A. EN2 is optional.
>
> Could EN ever be optional/fixed? If so, perhaps deprecate this property
> and do 2 properties, one for each pin.

The hardware I have has the EN2 pin fix connected to ground. Looking
into http://www.ti.com/lit/ds/slos743k/slos743k.pdf page 19 table 6-3
and 6-4 the EN2 pin is a don;t core if EN = 1. If EN = 0 EN2 pin
selects between Power Down and Sleep Mode ... I see no reason why
this is not possible/allowed ...

Hmm.. I do not like the idea of deprecating the "ti,enable-gpios"
property into 2 seperate properties ... but if this would be a reason
for not accepting this patch, I can do this ... How should I name
the 2 new properties?

"ti,pin-enable"  and "ti,pin-enable2" ?

bye,
Heiko
-- 
DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
