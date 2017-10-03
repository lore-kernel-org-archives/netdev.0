From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 net-next 0/8] flow_dissector: Protocol specific flow
 dissector offload
Date: Tue, 3 Oct 2017 09:46:32 +0200
Message-ID: <20171003074632.GD1916@nanopsycho>
References: <20170928235230.22158-1-tom@quantonium.net>
 <87y3oyylzv.fsf@stressinduktion.org>
 <CALx6S37J-Uv11TJuNFj4et==NFZj9W0v9s_c-Qowqcs--Kx_VQ@mail.gmail.com>
 <20170929.184245.412578447363431176.davem@davemloft.net>
 <CALx6S37DhT095fY92HWZAKQvMkqjxqq08nxJqL=wTP8JorHHDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:45285 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdJCHqe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 03:46:34 -0400
Received: by mail-wr0-f177.google.com with SMTP id m18so5671286wrm.2
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 00:46:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S37DhT095fY92HWZAKQvMkqjxqq08nxJqL=wTP8JorHHDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 29, 2017 at 07:59:35PM CEST, tom@herbertland.com wrote:
>On Fri, Sep 29, 2017 at 10:42 AM, David Miller <davem@davemloft.net> wrote:
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
>Then I would suggest adding another flag like FLOW_DISSECTOR_F_FLOWER
>and when anyone puts new code into flow_dissector they can wrap it
>with "if !(flags & FLOW_DISSECTOR_F_FLOWER)". If the flower uAPI is
>subsequently update then the conditional can be removed. This way
>flower can support maintain its APIs, but we can still still extend
>and improve flow_dissector for othersuse cases.

This is not flower-specific problem. Flow_dissector is a servant of many.
As such, it is instructed what should it do. If you want to
change the way inner headers are parsed, you should either:
1) change the callers so they are behaving the same as before
2) make the flow_dissection change optional so the caller can say if he
   wants original or new behaviour.
