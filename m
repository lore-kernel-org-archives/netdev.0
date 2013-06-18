From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v2 net-next] net: poll/select low latency socket support
Date: Tue, 18 Jun 2013 12:12:24 +0300
Message-ID: <51C02478.7020708@linux.intel.com>
References: <20130618085759.10941.15811.stgit@ladj378.jer.intel.com>  <20130618085810.10941.55039.stgit@ladj378.jer.intel.com> <1371546510.3252.224.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Avner Ben Hanoch <avnerb@mellanox.com>,
	Or Kehati <ork@mellanox.com>, sockperf-dev@googlegroups.com,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371546510.3252.224.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/06/2013 12:08, Eric Dumazet wrote:
> On Tue, 2013-06-18 at 11:58 +0300, Eliezer Tamir wrote:
>> select/poll busy-poll support.
>>
>
>
>>    */
>> -static inline u64 ll_end_time(struct sock *sk)
>> +static inline u64 ll_sk_end_time(struct sock *sk)
>>   {
>> -	u64 end_time = ACCESS_ONCE(sk->sk_ll_usec);
>> -
>> -	/* we don't mind a ~2.5% imprecision
>> -	 * sk->sk_ll_usec is a u_int so this can't overflow
>> -	 */
>> -	end_time = (end_time << 10) + sched_clock();
>> +	return (ACCESS_ONCE(sk->sk_ll_usec) << 10) + sched_clock();
>> +}
>>
>
> This is the fourth time you try to introduce an overflow in this code.
>
> (same for ll_end_time())

sorry,
Please review the rest of the patch to see if you have any other comments.
