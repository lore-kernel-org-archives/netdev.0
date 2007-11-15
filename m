From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter : struct xt_table_info diet
Date: Thu, 15 Nov 2007 13:26:40 +0100
Message-ID: <473C3B00.9090602@trash.net>
References: <20071114164735.1ba04bc3.dada1@cosmosbay.com>	<473B2E2D.4010504@trash.net> <20071114185544.034ee7d1.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20071114185544.034ee7d1.dada1@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Wed, 14 Nov 2007 18:19:41 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>>diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
>>>index 2909c92..ed3bd0b 100644
>>>--- a/net/ipv4/netfilter/arp_tables.c
>>>+++ b/net/ipv4/netfilter/arp_tables.c
>>>@@ -811,7 +811,7 @@ static int do_replace(void __user *user, unsigned int len)
>>> 		return -ENOPROTOOPT;
>>> 
>>> 	/* overflow check */
>>>-	if (tmp.size >= (INT_MAX - sizeof(struct xt_table_info)) / NR_CPUS -
>>>+	if (tmp.size >= (INT_MAX - XT_TABLE_INFO_SZ) / NR_CPUS -
>>> 			SMP_CACHE_BYTES)
>>
>>
>>Shouldn't NR_CPUs be replaced by nr_cpu_ids here? I'm wondering
>>why we still include NR_CPUs in the calculation at all though,
>>unlike in 2.4, we don't allocate one huge area of memory anymore
>>but do one allocation per CPU. IIRC it even was you who changed
>>that.
> 
> 
> Yes, doing an allocation per possible cpu was better than one giant 
> allocation (memory savings and NUMA aware)
> 
> Well, technically speaking you are right, we may also replace these 
> divides per NR_CPUS by nr_cpu_ids (or even better : num_possible_cpus())
> 
> Because with NR_CPUS=4096, we actually limit tmp.size to about 524000,
>  what a shame ! :)


We actually had complaints about number of rule limitations, but that
was more likely caused by vmalloc limits :) But of course we do need
to include the number of CPUs in the check, I misread the code.
