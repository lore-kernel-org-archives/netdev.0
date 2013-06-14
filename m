From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v4 net-next 2/4] net: convert low latency
	sockets to sched_clock()
Date: Fri, 14 Jun 2013 09:14:49 +0300
Message-ID: <51BAB4D9.2020803@linux.intel.com>
References: <20130614015638.3500.61523.stgit@ladj378.jer.intel.com>
	<20130614015659.3500.48625.stgit@ladj378.jer.intel.com>
	<1371179569.3252.120.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	linux-kernel@vger.kernel.org, sockperf-dev@googlegroups.com,
	Avner Ben Hanoch <avnerb@mellanox.com>, Andi Kleen <andi@firstfloor.org>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1371179569.3252.120.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 14/06/2013 06:12, Eric Dumazet wrote:
> On Fri, 2013-06-14 at 04:57 +0300, Eliezer Tamir wrote:
>> Use sched_clock() instead of get_cycles().
>> We can use sched_clock() because we don't care much about accuracy.
>> Remove the dependency on X86_TSC
>>
>> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> ---
>
>>
>> -static inline bool can_poll_ll(cycles_t end_time)
>> +static inline bool can_poll_ll(u64 end_time)
>>   {
>> -	return !time_after((unsigned long)get_cycles(),
>> +	return !time_after((unsigned long)sched_clock(),
>>   			    (unsigned long)end_time);
>>   }
>
> I do not really understand why you bother to have 64bit wide values,
> and then use these "unsigned long" casts here.
>
> On 32bit arches, this will really limit to 2^31 ns range.
>
> You should instead either :
> - use time_after_64() or
> - explicitly limit sysctl_net_ll_poll range

OK

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
