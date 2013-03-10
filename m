From: Vimal <j.vimal@gmail.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Sat, 9 Mar 2013 20:53:43 -0800
Message-ID: <CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com> <1362888229.4051.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, shemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:36215 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab3CJEyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 23:54:05 -0500
Received: by mail-wg0-f41.google.com with SMTP id ds1so1011266wgb.2
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 20:54:03 -0800 (PST)
In-Reply-To: <1362888229.4051.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, do you have suggestions on how to do this?  Maybe a better way to
do this would be to introduce an additional "multipler" option for
rates, which is set to 1 as default, so actual rate can be computed as
multipler * rate supplied.

On 9 March 2013 20:03, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2013-03-09 at 19:20 -0800, Vimalkumar wrote:
>> Since rate values are passed around between kernel and tc
>> in bytes/sec, 2**32 bytes/sec is around 34Gb/s.  Beyond that
>> rate, htb, tbf, hfsc, etc. can never be configured correctly.
>>
>> Signed-off-by: Vimalkumar <j.vimal@gmail.com>
>> ---
>>  include/linux/gen_stats.h |    2 +-
>>  include/linux/pkt_sched.h |   10 +++++-----
>>  misc/ifstat.c             |    4 ++--
>>  tc/m_police.c             |    2 +-
>>  tc/q_cbq.c                |    2 +-
>>  tc/q_choke.c              |    2 +-
>>  tc/q_gred.c               |    2 +-
>>  tc/q_hfsc.c               |    6 ++++--
>>  tc/q_red.c                |    2 +-
>>  tc/tc_cbq.c               |    4 ++--
>>  tc/tc_cbq.h               |    4 ++--
>>  tc/tc_core.c              |    4 ++--
>>  tc/tc_core.h              |    4 ++--
>>  tc/tc_util.c              |    6 +++---
>>  tc/tc_util.h              |    6 +++---
>>  15 files changed, 31 insertions(+), 29 deletions(-)
>>
>> diff --git a/include/linux/gen_stats.h b/include/linux/gen_stats.h
>> index 552c8a0..5ca6015 100644
>> --- a/include/linux/gen_stats.h
>> +++ b/include/linux/gen_stats.h
>> @@ -33,7 +33,7 @@ struct gnet_stats_basic_packed {
>>   * @pps: current packet rate
>>   */
>>  struct gnet_stats_rate_est {
>> -     __u32   bps;
>> +     __u64   bps;
>>       __u32   pps;
>>  };
>>
>> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
>> index 32aef0a..d6bc658 100644
>> --- a/include/linux/pkt_sched.h
>> +++ b/include/linux/pkt_sched.h
>> @@ -35,7 +35,7 @@ struct tc_stats {
>>       __u32   drops;                  /* Packets dropped because of lack of resources */
>>       __u32   overlimits;             /* Number of throttle events when this
>>                                        * flow goes out of allocated bandwidth */
>> -     __u32   bps;                    /* Current flow byte rate */
>> +     __u64   bps;                    /* Current flow byte rate */
>>       __u32   pps;                    /* Current flow packet rate */
>>       __u32   qlen;
>>       __u32   backlog;
>> @@ -79,7 +79,7 @@ struct tc_ratespec {
>>       unsigned short  overhead;
>>       short           cell_align;
>>       unsigned short  mpu;
>> -     __u32           rate;
>> +     __u64           rate;
>>  };
>>
>
> You cannot do that without breaking user land tools.
>
> Not only tc, but all user applications as well.
>
> We need to support compatibility, before considering adding such
> changes.
>
>
>



--
Vimal
