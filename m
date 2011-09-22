From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next v2] candev: allow SJW user setting for bittiming
	calculation
Date: Thu, 22 Sep 2011 21:41:23 +0200
Message-ID: <4E7B8F63.6060108@hartkopp.net>
References: <4E7B0DE6.9020807@hartkopp.net> <4E7B331F.3070801@grandegger.com>
	<4E7B61C8.8020506@hartkopp.net> <4E7B7A30.4030707@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E7B7A30.4030707-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

i put Pavel and Andrey into CC, maybe they also have an opinion about this.
I just talked to a specialist who told me, that a higher SJW is better - if
possible. And if an expert told me so and i had a simple config interface to
fullfill it, it would be great for me ;-)

Here is a link to the patch and this discussion:

http://patchwork.ozlabs.org/patch/115932/

Regards,
Oliver

On 09/22/11 20:10, Wolfgang Grandegger wrote:

> On 09/22/2011 06:26 PM, Oliver Hartkopp wrote:
>> On 09/22/11 15:07, Wolfgang Grandegger wrote:
>>
>>> Hi Oliver,
>>>
>>> On 09/22/2011 12:28 PM, Oliver Hartkopp wrote:
>>>> This patch adds support for SJW user settings to not set the synchronization
>>>> jump width (SJW) to 1 in any case when using the in-kernel bittiming
>>>> calculation.
>>>>
>>>> The ip-tool from iproute2 already supports to pass the user defined SJW
>>>> value. The given SJW value is sanitized with the controller specific sjw_max
>>>> and the calculated tseg2 value. As the SJW can have values up to 4 providing
>>>> this value will lead to the maximum possible SJW automatically. A higher SJW
>>>> allows higher controller oscillator tolerances.
>>
>> (..)
>>
>>
>>> As I already said, I expected "bt->sjw" to be always 0 when
>>> can_calc_bittiming() is called. But the software somehow allows to
>>> preset "bt->sjw", which is not intended as the help of the ip utility shows:
>>
>>
>> What was the technical reason for this 'not intended' that time?
> 
> Fiddling with SJW is something for *expert* only. You need to know
> what's going on the bus (electrically). To be clear, I'm not such an expert.
> 
>>> I actually hesitate to extend can_calc_bittiming(). I suggest using an
>>> external tool to calculate proper bit-timing parameters and set them
>>> with "ip link set DEVICE type can tq ...".
>>
>>
>> Yes, i know the possibility to specify the bittiming via time-quanta (tq).
> 
> This is what we called the "expert mode".
> 
>> But i think the in-kernel bittiming calculation is pretty good and solves most
>> usual cases. For me it's just an additional requirement to specify SJW as
> 
> What's your reason to increase SJW? Likely because you get bus errors
> with the standard settings. How should it be set? Likely you need to
> fiddle with other parameters as well. For sure, no business for a normal
> CAN user.
> 
>> MIN(tseg2, max_sjw) to extend the clock source tolerance - which can be
>> provided as an additional option to the bittiming calculation without pain
>> (IMO). If i can 'tune' the sample point, why should i not have any influence
>> to the synchronization jump width generation then?
> 
> Bitrate and sample point is something obvious for normal users.
> 
>> And btw. a help text can really be changed easily ;-)
>>
>> -        [ bitrate BITRATE [ sample-point SAMPLE-POINT] ] |
>> +        [ bitrate BITRATE [ sample-point SAMPLE-POINT] [sjw SJW] ] |
> 
> Well, I have stronger arguments against it ;-).
> 
> Any other opinions or suggestions?
> 
> Wolfgang.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
