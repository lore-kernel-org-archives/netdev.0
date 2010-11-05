From: Ben Greear <greearb@candelatech.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more per-cpu
 memory?
Date: Fri, 05 Nov 2010 13:26:58 -0700
Message-ID: <4CD46892.6050408@candelatech.com>
References: <4CD43C87.5040403@candelatech.com>	 <1288980361.2882.1070.camel@edumazet-laptop>	 <4CD449A5.5070305@candelatech.com> <1288988403.2665.268.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288988403.2665.268.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/05/2010 01:20 PM, Eric Dumazet wrote:

> Your vmalloc space is very fragmented. pcpu_get_vm_areas() want
> hugepages (4MB on your machine, 2MB on mine because I have
> CONFIG_HIGHMEM64G=y)
>
> You could :
>
> 1) Use a 64 bit kernel ( :) )

We mostly use 64-bit, but just not for the remastered live cd image.

> or
>
> 2) boot parameter vmalloc=256M   to get more room
>     (default is 128 Mbytes)

We'll try that.

>
> and eventually
>
> select a 2G/2G User/Kernel split to get more LOWMEM, because big vmalloc
> windows shrinks the LOWMEM zone. (CONFIG_VMSPLIT_2G=y)

That sounds promising as well.


I was also wondering if it would make sense to allow one to disable
the snmp stats for ipv6?  I don't think I have any use for those
stats anyway..

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
