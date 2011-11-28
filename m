From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v2 net-next 2/2] netem: add cell concept to simulate
 special MAC behavior
Date: Tue, 29 Nov 2011 00:30:04 +0100
Message-ID: <20111128233004.GH3045@nuttenaction>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
 <1322187773-27768-1-git-send-email-hagen@jauu.net>
 <1322187773-27768-2-git-send-email-hagen@jauu.net>
 <1322521267.2970.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57205 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755611Ab1K1XaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 18:30:08 -0500
Content-Disposition: inline
In-Reply-To: <1322521267.2970.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-11-29 00:01:07 [+0100]:

>> -static psched_time_t packet_len_2_sched_time(unsigned int len, u32 rate)
>> +static psched_time_t packet_len_2_sched_time(unsigned int len,
>> +					     struct netem_sched_data *q)
>>  {
>> -	return PSCHED_NS2TICKS((u64)len * NSEC_PER_SEC / rate);
>> +	len += q->packet_overhead;
>> +
>> +	if (q->cell_size) {
>> +		u32 carry = len % q->cell_size;
>> +		len += carry;
>
>I dont understand this part  (len += carry;)

Say the original packet is 100 byte, cellsize is 40 byte: three full size link
layer frames are required: 40 + 40 + 40 == 100 + 20. This is used for TDMA,
ATM or slot schemes where the remainder cannot be used.

Later in code carry is reused if cell overhead is configured.

>Also you use a lot of divides... Probably OK for netem...

I know, but

1) the branch is not hot (not taken at all if rate is not called)
2) cell_size could not restricted to a power of two - so I saw no real
   optimization potential.


Hagen
