From: santosh shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 05/14] RDS: defer the over_batch work to send worker
Date: Mon, 5 Oct 2015 08:31:00 -0700
Message-ID: <561297B4.8000403@oracle.com>
References: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
 <1443633873-13359-6-git-send-email-santosh.shilimkar@oracle.com>
 <20151005.033024.2236659260552514725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151005.033024.2236659260552514725.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/5/2015 3:30 AM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Date: Wed, 30 Sep 2015 13:24:24 -0400
>
>> @@ -423,7 +423,9 @@ over_batch:
>>   		     !list_empty(&conn->c_send_queue)) &&
>>   		    send_gen == conn->c_send_gen) {
>>   			rds_stats_inc(s_send_lock_queue_raced);
>> -			goto restart;
>> +			if (batch_count < 1024)
>> +				goto restart;
>> +			queue_delayed_work(rds_wq, &conn->c_send_w, 1);
>
> Sorry, you can't just use a magic number like this.
>
> You have to describe, in detail, exactly how this value was
> choosen, derived, and tested to be effeective and in exactly
> what environment those tests were done.
>
> You must also use a mnenomic for this value rather than a
> raw magic constant.
>
Right. Infact If I look at it now again, there is already a batch
count parameter which is module parameter. I will use that in
this hunk as well as the other couple places and send an update.

Thanks for review !!

Regards,
Santosh
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
