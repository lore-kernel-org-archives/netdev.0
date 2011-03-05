From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: comment rx_handler results
Date: Sat, 05 Mar 2011 16:50:49 +0100
Message-ID: <4D725BD9.6000706@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-8-git-send-email-jpirko@redhat.com> <1299329330.4277.97.camel@localhost> <20110305151331.GE8573@psychotron.redhat.com> <4D725678.2020706@gmail.com> <20110305153704.GI8573@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37964 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076Ab1CEPuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 10:50:52 -0500
Received: by wyg36 with SMTP id 36so3043055wyg.19
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 07:50:51 -0800 (PST)
In-Reply-To: <20110305153704.GI8573@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 16:37, Jiri Pirko a =E9crit :
> Sat, Mar 05, 2011 at 04:27:52PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Le 05/03/2011 16:13, Jiri Pirko a =E9crit :
>>>
>>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>> ---
>>>   include/linux/netdevice.h |   12 ++++++++----
>>>   1 files changed, 8 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index 48a9638..26e03f9 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -391,10 +391,14 @@ enum gro_result {
>>>   typedef enum gro_result gro_result_t;
>>>
>>>   enum rx_handler_result {
>>> -	RX_HANDLER_CONSUMED,
>>> -	RX_HANDLER_ANOTHER,
>>> -	RX_HANDLER_EXACT,
>>> -	RX_HANDLER_PASS,
>>> +	RX_HANDLER_CONSUMED,	/* skb was consumed by rx_handler,
>>> +				   do not process it further. */
>>> +	RX_HANDLER_ANOTHER,	/* Do another round in receive path.
>>> +				   This is indicated in case skb->dev
>>> +				   was changed by rx_handler */
>>> +	RX_HANDLER_EXACT,	/* Force exact delivery, no wildcard */
>>> +	RX_HANDLER_PASS,	/* Do nothing, pass the skb as if
>>> +				   no rx_handler was called */
>>
>> Changing skb->dev should always cause another_round.
>
> Not if you reinject the skb.
>
>>
>> So, RX_HANDLER_ANOTHER could be removed and replaced with a test for
>> skb->dev change, with RX_HANDER_EXACT and RX_HANDLER_PASS.
>
> That was there before. Needs extra variable and I think this way, via
> results the code is much easier to read.
>
>>
>>> +	RX_HANDLER_CONSUMED,	/* skb was consumed by rx_handler,
>>> +				   do not process it further. */
>>> +	RX_HANDLER_EXACT,	/* Force exact delivery, no wildcard */
>>> +	RX_HANDLER_PASS,	/* Do normal (wildcard and exact) delivery */
>>
>> And any rx_handler returning RX_HANDLER_EXACT should cause exact
>> delivery, even if possible next rx_handlers return RX_HANDLER_PASS.
>
> When rx_handler returns RX_HANDLER_EXACT, there will bo no other call=
 to
> any rx_handler (that is the case only when RX_HANDLER_ANOTHER is
> returned)

I agree, but we clearly need a kernel-doc that explain in more detail t=
he expected behavior of every=20
return values.

Some examples, showing some normal and some stacking setups, would help=
, I think. One more follow-up=20
patch...

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

	Nicolas.
