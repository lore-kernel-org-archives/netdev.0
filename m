From: Robert McCabe <robert.mccabe@rockwellcollins.com>
Subject: Re: [PATCH 1/1] tc: custom qdisc pkt size translation table
Date: Tue, 27 Jun 2017 12:37:40 -0500
Message-ID: <CAA0ESdrH+_1OhkuL7wmjjM-zNqY0o4qp5qDdfrNCR9LENCqbQQ@mail.gmail.com>
References: <20170627162917.20244-1-Robert.McCabe@rockwellcollins.com> <1498582512.736.119.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from da1vs01.rockwellcollins.com ([205.175.227.27]:32179 "EHLO
        da1vs01.rockwellcollins.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752911AbdF0RtI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 13:49:08 -0400
Received: by mail-yb0-f197.google.com with SMTP id o81so25296894ybg.4
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 10:37:41 -0700 (PDT)
In-Reply-To: <1498582512.736.119.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yeah, sorry didn't even think about that.
I guess my first question would be is there another way via the
iproute2 project where a user could
configure the stab->data pkt size translation table used in the
__qdisc_calculate_pkt_len method
in the kernel source (net/sched/sched_api.c)?

Also, let's say I went ahead and made the added TC_LINK_LAYER_CUSTOM
to the include/uapi/linux/pkt_sched.h
file in the kernel source ... would I also need to make the same
change in include/uapi/linux/pkt_sched.h in
the iproute2 source?

Do you recommend an alternative (more elegant) approach to what I'm
trying to accomplish?


On Tue, Jun 27, 2017 at 11:55 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-06-27 at 11:29 -0500, McCabe, Robert J wrote:
>> Added the "custom" linklayer qdisc stab option.
>> This allows the user to specify the pkt size translation
>> parameters from stdin.
>> Example:
>>    tc qdisc add ... stab tsize 8 linklayer custom htb
>>    Custom size table:
>>    InputSizeStart -> IntputSizeEnd: Output Pkt Size
>>    0 - 255: 400
>>    256 - 511: 800
>>    512 - 767: 1200
>>    768 - 1023: 1600
>>    1024 - 1279: 2000
>>    1280 - 1535: 2400
>>    1536 - 1791: 2800
>>    1792 - 2047: 3200
>>
>> Signed-off-by: McCabe, Robert J <Robert.McCabe@rockwellcollins.com>
>> ---
>>  include/linux/pkt_sched.h |  1 +
>>  tc/tc_core.c              | 51 +++++++++++++++++++++++++++++++++++++++++++++++
>>  tc/tc_core.h              |  2 +-
>>  tc/tc_stab.c              |  4 +++-
>>  tc/tc_util.c              |  5 +++++
>>  5 files changed, 61 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
>> index 099bf55..289bb81 100644
>> --- a/include/linux/pkt_sched.h
>> +++ b/include/linux/pkt_sched.h
>> @@ -82,6 +82,7 @@ enum tc_link_layer {
>>       TC_LINKLAYER_UNAWARE, /* Indicate unaware old iproute2 util */
>>       TC_LINKLAYER_ETHERNET,
>>       TC_LINKLAYER_ATM,
>> +     TC_LINKLAYER_CUSTOM,
>>  };
>>  #define TC_LINKLAYER_MASK 0x0F /* limit use to lower 4 bits */
>>
>
>
> You can not do this : This file is coming from the kernel
> ( include/uapi/linux/pkt_sched.h )
>
> Since your patch is user space only, you need to find another way ?
>
>
>
