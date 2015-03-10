From: Andy Zhou <azhou@nicira.com>
Subject: Re: [patch net-next 3/4] net: refactor IPv4 and IPv6 fragmentation APIs
Date: Tue, 10 Mar 2015 11:53:18 -0700
Message-ID: <CACzMAJL06gK4c5yHxaAA6TSZ6FwcKyoR1ziDAURWiVkhNDQoQg@mail.gmail.com>
References: <1425888098-21875-1-git-send-email-azhou@nicira.com>
	<1425888098-21875-4-git-send-email-azhou@nicira.com>
	<20150309092557.GB13498@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:47439 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751942AbbCJSxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 14:53:19 -0400
Received: by mail-ob0-f180.google.com with SMTP id vb8so3675213obc.10
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 11:53:18 -0700 (PDT)
In-Reply-To: <20150309092557.GB13498@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon and Eric, Thanks for the review.

Eric, I will fix the style issues raised. Thanks for pointing them out.

Simon, I reworked the API to remove the cast in the call back.  I will
post a V2 soon. Please take a look
and let me know if it addresses your concerns.

On Mon, Mar 9, 2015 at 2:25 AM, Simon Horman <simon.horman@netronome.com> wrote:
> On Mon, Mar 09, 2015 at 01:01:37AM -0700, Andy Zhou wrote:
>> Both ip_fragment() and ip6_fragment() APIs assume skb has an
>> attached netdev device, from which the MTU size can be derived.
>> However, skbs incoming from OVS vports do not have an attached
>> netdev device.
>>
>> This patch splits the original function into two parts: The core
>> fragmentation logic is now provided by
>> ip_fragment_mtu()/ip6_fragment_mut().
>>
>> The original APIs are kept as is. Their implementation now calls
>> the new APIs. Any information derived from the attached netdev
>> device is first derived in the original APIs and passed into the
>> new APIs.
>>
>> In addition, The call back output function into the new APIs now
>> accepts two arguments: a skb and an application specific pointer,
>> which specifies additional information not directly associated
>> with skb, such as OVS flow, to the output function.
>
> I suggest handling that portion of the change separately.
> It doesn't seem nearly as well defined as the rest of the change.
> And cast below seems somewhat undesirable to me.
>
> [snip]
>
>> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
>> index a7aea20..b85fd34 100644
>> --- a/net/ipv4/ip_output.c
>> +++ b/net/ipv4/ip_output.c
>
>> +     return ip_fragment_mtu(skb, mtu, ll_rs, NULL, dev,
>> +                     (int (*)(struct sk_buff *, void *output_arg))output);
>> +}
>>  EXPORT_SYMBOL(ip_fragment);
