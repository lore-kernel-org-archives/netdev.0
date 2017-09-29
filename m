From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v4 net-next 0/8] flow_dissector: Protocol specific flow
 dissector offload
Date: Fri, 29 Sep 2017 11:04:23 -0700
Message-ID: <CALx6S378z0FPWBdpC8-OKjqMwwSDO8BpxJmifvOUSMkEa8d0+Q@mail.gmail.com>
References: <20170928235230.22158-1-tom@quantonium.net> <87y3oyylzv.fsf@stressinduktion.org>
 <CALx6S37J-Uv11TJuNFj4et==NFZj9W0v9s_c-Qowqcs--Kx_VQ@mail.gmail.com>
 <20170929.184245.412578447363431176.davem@davemloft.net> <CALx6S37DhT095fY92HWZAKQvMkqjxqq08nxJqL=wTP8JorHHDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:49736 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752159AbdI2SEZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 14:04:25 -0400
Received: by mail-qk0-f179.google.com with SMTP id u67so410019qkg.6
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 11:04:24 -0700 (PDT)
In-Reply-To: <CALx6S37DhT095fY92HWZAKQvMkqjxqq08nxJqL=wTP8JorHHDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 10:59 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Sep 29, 2017 at 10:42 AM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Fri, 29 Sep 2017 08:48:55 -0700
>>
>>> The flow_dissector interface is not a uAPI.
>>
>> That's not true, insofar as cls_flower.c uses the flow_dissector
>> therefore if you change the flow_dissector in certain ways then
>> cls_flower.c might have it's behavior changed and that is in fact UAPI
>> facing.
>
> Then I would suggest adding another flag like FLOW_DISSECTOR_F_FLOWER
> and when anyone puts new code into flow_dissector they can wrap it
> with "if !(flags & FLOW_DISSECTOR_F_FLOWER)". If the flower uAPI is
> subsequently update then the conditional can be removed. This way
> flower can support maintain its APIs, but we can still still extend
> and improve flow_dissector for othersuse cases.
>
Actually, it would make more sense to have the converse so we don't
have to touch flower. I will add FLOW_DISSECTOR_F_NOT_FLOWER

> Tom
