From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC] flow_dissector: Add FLOW_DISSECTOR_F_FLOWER
Date: Mon, 2 Oct 2017 09:05:10 -0700
Message-ID: <CALx6S356v5Ogwv0G3Pnok2FkFphNbkw-cRR5MRtQRDmV2_vMXA@mail.gmail.com>
References: <20170929191343.11318-1-tom@quantonium.net> <20171002144946.GE1941@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35392 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbdJBQFM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 12:05:12 -0400
Received: by mail-qk0-f193.google.com with SMTP id w63so2582557qkd.2
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 09:05:11 -0700 (PDT)
In-Reply-To: <20171002144946.GE1941@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 2, 2017 at 7:49 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Sep 29, 2017 at 09:13:42PM CEST, tom@quantonium.net wrote:
>>This patch is RFC and would be applied after "flow_dissector:
>>Protocol specific flow dissector offload"
>>
>>In order to maitain uAPI in flower, the FLOW_DISSECTOR_F_FLOWER flag
>>is added to indicate to flow_dissector that the caller is flower.
>>As new funtionality is addes to flow_dissector that would break
>>the flower uAPI, the code can be wrapped in "if (!(flags &
>>FLOW_DISSECTOR_F_FLOWER)).
>>
>>In this patch the conditional is use around protocol specific
>>dissection (e.g. DPI into VXLAN) as well as the code that
>>enforces a depth of parsing to prevent DPI. The latter was a
>>recent patch that would introduce a parsing limit to flower that
>>did not exist before (i.e. would break uAPI).
>>
>>Signed-off-by: Tom Herbert <tom@quantonium.net>
>>---
>> include/net/flow_dissector.h |  1 +
>> net/core/flow_dissector.c    | 17 +++++++++++------
>> net/sched/cls_flow.c         |  3 ++-
>> 3 files changed, 14 insertions(+), 7 deletions(-)
>>
>>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>>index ad75bbfd1c9c..ca315107d147 100644
>>--- a/include/net/flow_dissector.h
>>+++ b/include/net/flow_dissector.h
>>@@ -214,6 +214,7 @@ enum flow_dissector_key_id {
>> #define FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL   BIT(2)
>> #define FLOW_DISSECTOR_F_STOP_AT_ENCAP                BIT(3)
>> #define FLOW_DISSECTOR_F_STOP_AT_L4           BIT(4)
>>+#define FLOW_DISSECTOR_F_FLOWER                       BIT(5)
>
> I don't like flow_dissector to have any user-specific bits. Note that
> the same dissection may be used not only from flower, but from other
> code as well (OVS). Flow dissector should not care who the caller is.

I agree with that, but unfortunately that's now how it works in
reality. As pointed out flower has assumed flow_dissector semantics as
its uAPI, so we can't change flow dissector with out considering this
one specific caller even if all other use cases of flow dissector
don't care.

If you don't like this approach, then please suggest an alternative
that will achieve the same effect.

Thanks,
Tom
