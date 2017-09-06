From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net] rds: Fix incorrect statistics counting
Date: Wed, 6 Sep 2017 08:58:16 -0700
Message-ID: <b620a15a-e60e-5c35-ffef-ee485d338774@oracle.com>
References: <20170906152950.17766-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        knut.omang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
To: =?UTF-8?Q?H=c3=a5kon_Bugge?= <Haakon.Bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170906152950.17766-1-Haakon.Bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 9/6/2017 8:29 AM, Håkon Bugge wrote:
> In rds_send_xmit() there is logic to batch the sends. However, if
> another thread has acquired the lock, it is considered a race and we
> yield. The code incrementing the s_send_lock_queue_raced statistics
> counter did not count this event correctly.
> 
> This commit removes a small race in determining the race and
> increments the statistics counter correctly.
> 
> Signed-off-by: Håkon Bugge <haakon.bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Knut Omang <knut.omang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>   net/rds/send.c | 16 +++++++++++++---
>   1 file changed, 13 insertions(+), 3 deletions(-)
> 
Those counters are not really to give that accurate so
am not very keen to add additional cycles in send paths
and add additional code. Have you seen any real issue
or this is just a observation. s_send_lock_queue_raced
counter is never used to check for smaller increments
and hence the question.

Regards,
Santosh
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
