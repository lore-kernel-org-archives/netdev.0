From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: Fwd: [BUG] Bisected Gianfar not receiving any traffic
Date: Mon, 10 Jun 2013 13:03:43 +0300
Message-ID: <51B5A47F.9010700@freescale.com>
References: <CALG0vJsttWB4=fDU5yiRdf0rKgp09pY1y1jq5Ug_ra-7M7KQBQ@mail.gmail.com> <CALG0vJuENcAnrpP1Bbe2-KhV8=oazLn7pMnvC6XTNCYnAMvOhw@mail.gmail.com> <51B58E52.1080008@freescale.com> <CALG0vJtYfhJOMMU1rgDV8TYgkm3MJh2iibqmAJsj3nxbegBWEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Michael Guntsche <michael.guntsche@it-loops.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0186.outbound.messaging.microsoft.com ([213.199.154.186]:59406
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752759Ab3FJKEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 06:04:12 -0400
In-Reply-To: <CALG0vJtYfhJOMMU1rgDV8TYgkm3MJh2iibqmAJsj3nxbegBWEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, this is a TSEC controller (an old model indeed) and looks like
it doesn't have the frame receive indication (RXF) field in RSTAT.
I'll send fix for this case asap.
I think the real problem here is that the driver supports multiple
rings per interrupt line. With a single ring per interrupt / CPU,
we would get rid of the overhead and related issues of looking for
active rings in the napi poll routine.

Claudiu

On 6/10/2013 11:33 AM, Michael Guntsche wrote:
> Hello Claudiu,
>
> The Board in question is a Mikrotik Routerboard RB600A, which is
> using a MPC8343E.
>
> /Michael
>
> On Mon, Jun 10, 2013 at 10:29 AM, Claudiu Manoil
> <claudiu.manoil@freescale.com> wrote:
>> Hello,
>>
>> Please provide the model of your board. Commit 6be5ed3fef568 relies
>> on correct indication from H/W for Rx processing, so we should
>> check whether the right register/mask are being used for that model
>> or whether there's a missing errata. One way to confirm this is by
>> checking if Rx processing (and not Tx) is entered with
>> num_act_queues == 0 (the RXF indication set to 0).
>>
>> Thanks, Claudiu
>>
>>
>> On 6/9/2013 11:28 PM, Michael Guntsche wrote:
>>>
>>> Forwarded to the correct mailing list address.
>>>
>>>
>>> ---------- Forwarded message ---------- From: Michael Guntsche
>>> <michael.guntsche@it-loops.com> Date: Sun, Jun 9, 2013 at 10:26
>>> PM Subject: [BUG] Bisected Gianfar not receiving any traffic To:
>>> linux-netdev@vger.kernel.org Cc: Claudiu Manoil
>>> <claudiu.manoil@freescale.com>
>>>
>>>
>>> Good evening,
>>>
>>> While testing one of my powerpc based embedded ports I noticed
>>> that with any 3.10-rc kernel ethernet traffic was dead on my two
>>> gianfar NICs. The strange thing was that apparetnly outbound
>>> broadcasts seemed to work since avahi correctly registered the
>>> name of the board. I bisected it to the following commit.
>>>
>>> 6be5ed3fef568 gianfar: Poll only active Rx queues
>>>
>>> Reverting this commit on 3.10-rc4 made both gianfar devices work
>>> again. This is a rather old board so it could be that the
>>> register that's used here is just plain wrong in my case. A few
>>> years ago I had a similar issue where the implementation on the
>>> board here apparently did not work correctly.
>>>
>>> http://marc.info/?l=linux-netdev&m=131297524825104&w=2
>>>
>>> In that case a flag was bogus as well. If you need more
>>> information or want me to test a patch please add me as CC since
>>> I am not subscribed to the list.
>>>
>>> Kind regards, Michael Guntsche -- To unsubscribe from this list:
>>> send the line "unsubscribe netdev" in the body of a message to
>>> majordomo@vger.kernel.org More majordomo info at
>>> http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>
>>
> -- To unsubscribe from this list: send the line "unsubscribe netdev"
> in the body of a message to majordomo@vger.kernel.org More majordomo
> info at  http://vger.kernel.org/majordomo-info.html
>
>
