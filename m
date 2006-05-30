From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: drivers/connector/cn_queue.c:130: warning: value computed is not used
Date: Tue, 30 May 2006 15:48:38 +0400
Message-ID: <20060530114838.GA20906@2ka.mipt.ru>
References: <jeac8zg311.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:3538 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750940AbWE3MBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 08:01:17 -0400
To: Andreas Schwab <schwab@suse.de>
Content-Disposition: inline
In-Reply-To: <jeac8zg311.fsf@sykes.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2006 at 01:34:02PM +0200, Andreas Schwab (schwab@suse.de) wrote:
> There is no point in testing the atomic value if the result is thrown
> away.

It was created to put implicit smp barrier, but it is not needed there.
Your patch is correct, thank you.

> Signed-off-by: Andreas Schwab <schwab@suse.de>

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

> diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
> index 9f2f00d..05f8ce2 100644
> --- a/drivers/connector/cn_queue.c
> +++ b/drivers/connector/cn_queue.c
> @@ -127,7 +127,7 @@ void cn_queue_del_callback(struct cn_que
>  
>  	if (found) {
>  		cn_queue_free_callback(cbq);
> -		atomic_dec_and_test(&dev->refcnt);
> +		atomic_dec(&dev->refcnt);
>  	}
>  }
>  
> 
> Andreas.

-- 
	Evgeniy Polyakov
