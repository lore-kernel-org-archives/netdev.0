From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH v4 net-next 0/8] flow_dissector: Protocol specific flow
 dissector offload
Date: Tue, 3 Oct 2017 11:35:54 -0700
Message-ID: <CAPDqMeq3er9=P9AUFKf4-FcSgthpv2hUz+WTb78DRHGEJ0TTWA@mail.gmail.com>
References: <20170928235230.22158-1-tom@quantonium.net> <87y3oyylzv.fsf@stressinduktion.org>
 <CALx6S37J-Uv11TJuNFj4et==NFZj9W0v9s_c-Qowqcs--Kx_VQ@mail.gmail.com>
 <20170929.184245.412578447363431176.davem@davemloft.net> <CALx6S37DhT095fY92HWZAKQvMkqjxqq08nxJqL=wTP8JorHHDg@mail.gmail.com>
 <20171003074632.GD1916@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:56631 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdJCSf4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 14:35:56 -0400
Received: by mail-wm0-f44.google.com with SMTP id l68so4954831wmd.5
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 11:35:56 -0700 (PDT)
In-Reply-To: <20171003074632.GD1916@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 3, 2017 at 12:46 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Sep 29, 2017 at 07:59:35PM CEST, tom@herbertland.com wrote:
>>On Fri, Sep 29, 2017 at 10:42 AM, David Miller <davem@davemloft.net> wrote:
>>> From: Tom Herbert <tom@herbertland.com>
>>> Date: Fri, 29 Sep 2017 08:48:55 -0700
>>>
>>>> The flow_dissector interface is not a uAPI.
>>>
>>> That's not true, insofar as cls_flower.c uses the flow_dissector
>>> therefore if you change the flow_dissector in certain ways then
>>> cls_flower.c might have it's behavior changed and that is in fact UAPI
>>> facing.
>>
>>Then I would suggest adding another flag like FLOW_DISSECTOR_F_FLOWER
>>and when anyone puts new code into flow_dissector they can wrap it
>>with "if !(flags & FLOW_DISSECTOR_F_FLOWER)". If the flower uAPI is
>>subsequently update then the conditional can be removed. This way
>>flower can support maintain its APIs, but we can still still extend
>>and improve flow_dissector for othersuse cases.
>
> This is not flower-specific problem. Flow_dissector is a servant of many.

Besides flower, what other use cases of flow_dissector have made
flow_dissector interface a uAPI? Any use of hashing does not do this.
Maybe OVS does?

> As such, it is instructed what should it do. If you want to
> change the way inner headers are parsed, you should either:

Why would that only affect the way inner headers are parsed? Wouldn't
we need to consider any change to flow_dissector that might affect the
output in any way. For instance, the depth limits I added would change
to output for someone that was parsing thirty-five layers of
encapsulation so it it looks like that feature needs a flag. What if
someone adds a new Ethernet protocol or a new encap protocol?

> 1) change the callers so they are behaving the same as before
> 2) make the flow_dissection change optional so the caller can say if he
>    wants original or new behaviour.

I guess we can do that, but am concerned about the overhead this will
generate if were adding a flag each time anyone modifies the function.
There are performance critical use cases of flow_dissector that will
be impacted by such changes.

Tom


>
