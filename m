From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH v1 net-next] net: pkt_sched: PIE AQM scheme
Date: Tue, 1 Oct 2013 20:59:29 -0700
Message-ID: <CAGK4HS-zdnS3qDhR3oRSW=oxusG16=icZ62yzkLM8zc1Sn8A3Q@mail.gmail.com>
References: <1902752B0C92F943AB7EA9EE13E2DEEC1272C74DD1@HQ1-EXCH02.corp.brocade.com>
	<20130928100637.4c69571e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	Dave Taht <dave.taht@bufferbloat.net>,
	"Mythili Suryanarayana Prabhu (mysuryan)" <mysuryan@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f43.google.com ([209.85.212.43]:38164 "EHLO
	mail-vb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703Ab3JBD7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 23:59:30 -0400
Received: by mail-vb0-f43.google.com with SMTP id h11so159564vbh.16
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 20:59:29 -0700 (PDT)
In-Reply-To: <20130928100637.4c69571e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks for all the reviews. It is much appreciated.

>> +
>> +typedef u32 pie_time_t;
>> +typedef s32 pie_tdiff_t;
>> +#define PIE_SHIFT 10
>> +#define MS2PIETIME(a) ((a * NSEC_PER_MSEC) >> PIE_SHIFT)
>> +#define PIE_TIME_PER_SEC  ((NSEC_PER_SEC >> PIE_SHIFT))
>> +
>
> I would prefer that all packet schedulers use the same set of clock
> routines (psched), rather than inventing own wrapper for high resolution
> clock.
>
>> +static inline pie_time_t pie_get_time(void)
>> +{
>> +       u64 ns = ktime_to_ns(ktime_get());
>> +       return ns >> PIE_SHIFT;
>> +}
>> +
>> +static inline u32 pie_time_to_ms(pie_time_t val)
>> +{
>> +       u64 valms = ((u64) val << PIE_SHIFT);
>> +
>> +       do_div(valms, NSEC_PER_MSEC);
>> +       return (u32) valms;
>> +}
>
> Psched has all this.
>

I did have a version that used only psched. I believe it uses a 64
nsec clock. It turned out that the algorithm (ar at least the
implementation) was having issue at that high granularity
so I used a lower resolution clock built on top of psched. Is there a
way to build a use psched at a lower resolution?

Also, pkt_sched.h contains just a couple of functions , mainly
psched_get_time()? Are there functions that convert psched-ticks to ms
or us?
Or that compare psched-ticks such as time_after() or time_before()?
Your comment seems to suggest there are.

If someone can provide any pointers, it will be appreciated. Hope I am
not missing anything obvious.


>
> Please fix and resubmit. This is just a first pass review, there are
> probably more detailed issues that others will see.
>

I will address the issues that Eric, you and DavidL pointed out so far
and send a V2 shortly.

Thanks to all reviewers,
Vijay
