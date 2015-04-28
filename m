From: Ido Shamay <idos@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4: Fix tx ring affinity_mask creation
Date: Tue, 28 Apr 2015 16:37:33 +0300
Message-ID: <553F8D1D.3040803@dev.mellanox.co.il>
References: <1428683240-22879-1-git-send-email-bpoirier@suse.de> <552A18A8.1040109@dev.mellanox.co.il> <20150414002256.GA22775@f1.synalogic.ca> <20150428032637.GA6169@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ido Shamay <idos@mellanox.com>
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150428032637.GA6169@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/28/2015 6:26 AM, Benjamin Poirier wrote:
> On 2015/04/13 17:22, Benjamin Poirier wrote:
>> On 2015/04/12 10:03, Ido Shamay wrote:
>>> Hi Benjamin,
>>>
>>> On 4/10/2015 7:27 PM, Benjamin Poirier wrote:
>>>> By default, the number of tx queues is limited by the number of online cpus in
>>>> mlx4_en_get_profile(). However, this limit no longer holds after the ethtool
>>>> .set_channels method has been called. In that situation, the driver may access
>>>> invalid bits of certain cpumask variables when queue_index > nr_cpu_ids.
>>> I must say I don't see the above issue with the current code.
>>> Whatever is the modified value of priv->num_tx_rings_p_up, it will set XPS
>>> only on queues which have
>>> been set with CPU affinity mask (no access to invalid bits).
>> The problem is not with the call to netif_set_xps_queue() it is with the
>> calls to cpu_online() and cpumask_set_cpu().
>>
>> For example, if the user calls `ethtool -L ethX tx 32`, queue_index in
>> mlx4_en_create_tx_ring() can be up to 255. Depending on CONFIG_NR_CPUS
>> and CONFIG_CPUMASK_OFFSTACK this may result in calls to cpu_online() and
>> cpumask_set_cpu() with cpu >= nr_cpumask_bits which is an invalid usage
>> of the cpumask api. The driver will potentially read or write beyond the
>> end of the bitmap. With CONFIG_CPUMASK_OFFSTACK=y and
>> CONFIG_DEBUG_PER_CPU_MAPS=y, the aforementioned ethtool call on a system
>> with <32 cpus triggers the warning in cpumask_check().
>>
> Mellanox, can you please
> ack the patch as submitted, or
> clarify what changes you'd like to see given my reply above, or
> submit a fix of your own for this problem
>
> Thanks,
> -Benjamin
Hi Benjamin,

After further review and better understanding of the issue, we are okay 
with your patch as is.
Thanks for the good work.

Acked-by: Ido Shamay <idos@mellanox.com>
