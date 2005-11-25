From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH (resent with the attachment !)] netfilter : zap
 get_cpu()/put_cpu() calls from ip_tables
Date: Fri, 25 Nov 2005 19:20:42 +0100
Message-ID: <438755FA.90704@trash.net>
References: <432EF0C5.5090908@cosmosbay.com> <200509191948.55333.ak@suse.de>
	<432FDAC5.3040801@cosmosbay.com> <200509201830.20689.ak@suse.de>
	<433082DE.3060308@cosmosbay.com> <43308324.70403@cosmosbay.com>
	<4331CFA7.50104@cosmosbay.com> <4386F440.5020505@cosmosbay.com>
	<4386F56F.7020205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, Andrew Morton <akpm@osdl.org>,
	netfilter-devel@lists.netfilter.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <4386F56F.7020205@cosmosbay.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> The 'ip_tables: NUMA-aware allocation' patch 
> (http://www.kernel.org/git/?p=linux/kernel/git/davem/net-2.6.16.git;a=commit;h=6d1273850cac8db77c462caaa145b813d93adc55) 
> 
> introduced a problem with get_cpu()/put_cpu()
> 
> The problem is that get_cpu() disables preemption and the thread is not 
> allowed to sleep.
> 
> As the intent was only to give a hint, relax the enforcement and switch 
> to a hint : If the current thread is preempted and migrated to another 
> cpu, this is not a problem. Most of the time, thread wont be migrated 
> anyway.
> 
> This patch removes get_cpu()/put_cpu() pairs and uses 
> raw_smp_processor_id() were appropriate.

Looks good, thanks. I'm going to test it and pass it on to Dave if it
works.
