From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] vhost: apply cpumask and cgroup to vhost workers
Date: Wed, 02 Jun 2010 01:59:32 +0200
Message-ID: <4C059EE4.5070104@kernel.org>
References: <20100527163954.GA21710@redhat.com>	 <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com>	 <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com>	 <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com>	 <4C02C961.9050606@kernel.org> <20100531152221.GB2987@redhat.com>	 <4C03D983.9010905@kernel.org> <20100531160020.GC3067@redhat.com>	 <4C04D453.9040208@kernel.org> <1275412754.989.10.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Oleg Nesterov <oleg@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275412754.989.10.camel@w-sridhar.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/01/2010 07:19 PM, Sridhar Samudrala wrote:
>> -	int i;
>> +	cpumask_var_t mask;
>> +	int i, ret = -ENOMEM;
>> +
>> +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
>> +		goto out_free_mask;
> 
> I think this is another bug in the error path. You should simply
> do a return instead of a goto here when aloc_cpu_mask fails.

Oh... it's always safe to call free_cpumask_var() after failed
alloc_cpumask_var(), so that part isn't broken.

Thanks.

-- 
tejun
