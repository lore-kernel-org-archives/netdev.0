From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 05/14] RDS: defer the over_batch work to send worker
Date: Mon, 05 Oct 2015 03:30:24 -0700 (PDT)
Message-ID: <20151005.033024.2236659260552514725.davem@davemloft.net>
References: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
	<1443633873-13359-6-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443633873-13359-6-git-send-email-santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Wed, 30 Sep 2015 13:24:24 -0400

> @@ -423,7 +423,9 @@ over_batch:
>  		     !list_empty(&conn->c_send_queue)) &&
>  		    send_gen == conn->c_send_gen) {
>  			rds_stats_inc(s_send_lock_queue_raced);
> -			goto restart;
> +			if (batch_count < 1024)
> +				goto restart;
> +			queue_delayed_work(rds_wq, &conn->c_send_w, 1);

Sorry, you can't just use a magic number like this.

You have to describe, in detail, exactly how this value was
choosen, derived, and tested to be effeective and in exactly
what environment those tests were done.

You must also use a mnenomic for this value rather than a
raw magic constant.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
