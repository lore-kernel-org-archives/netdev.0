From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] netprio_cgroup: Optimize the priomap copy loop slightly
Date: Wed, 12 Sep 2012 11:35:24 +0530
Message-ID: <50502624.8040409@linux.vnet.ibm.com>
References: <20120911112231.13852.61794.stgit@srivatsabhat.in.ibm.com> <20120911112237.13852.1095.stgit@srivatsabhat.in.ibm.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FE9@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com,
	john.r.fastabend@intel.com, gaofeng@cn.fujitsu.com,
	eric.dumazet@gmail.com, mark.d.rustad@intel.com,
	lizefan@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE9@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/11/2012 05:12 PM, David Laight wrote:
>> -	for (i = 0;
>> -	     old_priomap && (i < old_priomap->priomap_len);
>> -	     i++)
>> -		new_priomap->priomap[i] = old_priomap->priomap[i];
>> +	if (old_priomap) {
>> +		old_len = old_priomap->priomap_len;
>> +
>> +		for (i = 0; i < old_len; i++)
>> +			new_priomap->priomap[i] = old_priomap->priomap[i];
>> +	}
> 
> Or:
> 	memcpy(new_priomap->priomap, old_priomap->priomap,
> 		old_priomap->priomap_len * sizeof old_priomap->priomap[0]);
> 

Ah, indeed that would be better. I'll send out an updated version of the
patches. Thanks!

Regards,
Srivatsa S. Bhat
