From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Thu, 28 May 2015 08:45:50 -0700
Message-ID: <5567382E.4010706@gmail.com>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com> <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com> <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net> <1432826085.7456.6.camel@edumazet-glaptop2.roam.corp.google.com> <746223891.124020.1432827038389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33740 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbbE1Pq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 11:46:29 -0400
Received: by oiww2 with SMTP id w2so35483530oiw.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 08:46:28 -0700 (PDT)
In-Reply-To: <746223891.124020.1432827038389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2015 08:30 AM, jsullivan@opensourcedevel.com wrote:
>
>> On May 28, 2015 at 11:14 AM Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>>
>> On Thu, 2015-05-28 at 10:38 -0400, jsullivan@opensourcedevel.com wrote:
>>
> <snip>
>> IFB has still a long way before being efficient.
>>
>> In the mean time, you could play with following patch, and
>> setup /sys/class/net/eth0/gro_timeout to 20000
>>
>> This way, the GRO aggregation will work even at 1Gbps, and your IFB will
>> get big GRO packets instead of single MSS segments.
>>
>> Both IFB but also IP/TCP stack will have less work to do,
>> and receiver will send fewer ACK packets as well.
>>
>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
>> b/drivers/net/ethernet/intel/igb/igb_main.c
>> index
>> f287186192bb655ba2dc1a205fb251351d593e98..c37f6657c047d3eb9bd72b647572edd53b1881ac
>> 100644
>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>> @@ -151,7 +151,7 @@ static void igb_setup_dca(struct igb_adapter *);
>> #endif /* CONFIG_IGB_DCA */
> <snip>
>
> Interesting but this is destined to become a critical production system for a
> high profile, internationally recognized product so I am hesitant to patch.  I
> doubt I can convince my company to do it but is improving IFB the sort of
> development effort that could be sponsored and then executed in a moderately
> short period of time? Thanks - John
> --

If your experimenting one thing you could do is create many
ifb devices and load balance across them from tc. I'm not
sure if this would be practical in your setup or not but might
be worth trying.

One thing I've been debating adding is the ability to match
on current cpu_id in tc which would allow you to load balance by
cpu. I could send you a patch if you wanted to test it. I would
expect this to help somewhat with 'single queue' issue but sorry
haven't had time yet to test it out myself.

.John

-- 
John Fastabend         Intel Corporation
