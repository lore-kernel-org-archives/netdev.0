From: santosh shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 00/15] RDS: connection scalability and performance
 improvements
Date: Mon, 21 Sep 2015 09:02:11 -0700
Message-ID: <56002A03.5060305@oracle.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
 <55FE7060.6010205@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sagi Grimberg <sagig-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55FE7060.6010205-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 9/20/2015 1:37 AM, Sagi Grimberg wrote:
> On 9/20/2015 2:04 AM, Santosh Shilimkar wrote:
>> This series addresses RDS connection bottlenecks on massive workloads and
>> improve the RDMA performance almost by 3X. RDS TCP also gets a small gain
>> of about 12%.
>>
>> RDS is being used in massive systems with high scalability where several
>> hundred thousand end points and tens of thousands of local processes
>> are operating in tens of thousand sockets. Being RC(reliable connection),
>> socket bind and release happens very often and any inefficiencies in
>> bind hash look ups hurts the overall system performance. RDS bin
>> hash-table
>> uses global spin-lock which is the biggest bottleneck. To make matter
>> worst,
>> it uses rcu inside global lock for hash buckets.
>> This is being addressed by simply using per bucket rw lock which makes
>> the
>> locking simple and very efficient. The hash table size is also scaled up
>> accordingly.
>>
>> For RDS RDMA improvement, the completion handling is revamped so that we
>> can do batch completions. Both send and receive completion handlers are
>> split logically to achieve the same. RDS 8K messages being one of the
>> key usecase, mr pool is adapted to have the 8K mrs along with default 1M
>> mrs. And while doing this, few fixes and couple of bottlenecks seen with
>> rds_sendmsg() are addressed.
>
> Hi Santosh,
>
> I think that can get a more effective code review if you CC the
> Linux-rdma mailing list.
>
I will do that from next time. Thanks Sagi !!

Regards,
Santosh
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
