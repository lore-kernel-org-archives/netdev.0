From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v4 net-next] net: poll/select low latency socket support
Date: Fri, 28 Jun 2013 08:32:26 +0300
Message-ID: <51CD1FEA.5020603@linux.intel.com>
References: <20130624072751.26134.78163.stgit@ladj378.jer.intel.com> <20130624072803.26134.41593.stgit@ladj378.jer.intel.com> <20130628044305.GQ6123@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130628044305.GQ6123@two.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/06/2013 07:43, Andi Kleen wrote:
>> @@ -400,6 +402,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>>   	poll_table *wait;
>>   	int retval, i, timed_out = 0;
>>   	unsigned long slack = 0;
>> +	unsigned int ll_flag = POLL_LL;
>> +	u64 ll_time = ll_end_time();
>
> So you're adding a sched_clock to every select call, even if it has
> nothing to do with ll?
>
> That seems rather drastic. select can be performance critical.

would the following be acceptable?

	unsigned int ll_flag = ll_poll_enabled(); // returns POLL_LL if on
	u64 ll_time = ll_flag ? ll_end_time() : 0;

and at the other side
	
	if (ll_flag && can_poll_ll(ll_end_time))
		continue;


-Eliezer
