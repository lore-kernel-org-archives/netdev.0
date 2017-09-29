From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v4 net-next 0/8] flow_dissector: Protocol specific flow
 dissector offload
Date: Fri, 29 Sep 2017 10:59:35 -0700
Message-ID: <CALx6S37DhT095fY92HWZAKQvMkqjxqq08nxJqL=wTP8JorHHDg@mail.gmail.com>
References: <20170928235230.22158-1-tom@quantonium.net> <87y3oyylzv.fsf@stressinduktion.org>
 <CALx6S37J-Uv11TJuNFj4et==NFZj9W0v9s_c-Qowqcs--Kx_VQ@mail.gmail.com> <20170929.184245.412578447363431176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:54475 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752120AbdI2R7h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 13:59:37 -0400
Received: by mail-qt0-f182.google.com with SMTP id i13so526173qtc.11
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 10:59:36 -0700 (PDT)
In-Reply-To: <20170929.184245.412578447363431176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 10:42 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Fri, 29 Sep 2017 08:48:55 -0700
>
>> The flow_dissector interface is not a uAPI.
>
> That's not true, insofar as cls_flower.c uses the flow_dissector
> therefore if you change the flow_dissector in certain ways then
> cls_flower.c might have it's behavior changed and that is in fact UAPI
> facing.

Then I would suggest adding another flag like FLOW_DISSECTOR_F_FLOWER
and when anyone puts new code into flow_dissector they can wrap it
with "if !(flags & FLOW_DISSECTOR_F_FLOWER)". If the flower uAPI is
subsequently update then the conditional can be removed. This way
flower can support maintain its APIs, but we can still still extend
and improve flow_dissector for othersuse cases.

Tom
