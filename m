From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH v2 07/17] net: sched: drop qdisc_reset from
 dev_graft_qdisc
Date: Tue, 2 May 2017 22:00:53 +0200
Message-ID: <20170502220053.0b460e38@redhat.com>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
        <20170502153819.9304.39271.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42082 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751074AbdEBUBA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 16:01:00 -0400
In-Reply-To: <20170502153819.9304.39271.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 May 2017 08:38:19 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> @@ -991,20 +996,25 @@ void dev_deactivate_many(struct list_head *head)
>  					     &noop_qdisc);
>  
>  		dev_watchdog_down(dev);
> -		sync_needed |= !dev->dismantle;
>  	}
>  
>  	/* Wait for outstanding qdisc-less dev_queue_xmit calls.
>  	 * This is avoided if all devices are in dismantle phase :
>  	 * Caller will call synchronize_net() for us
>  	 */

Is the comment still correct after this change?

> -	if (sync_needed)
> -		synchronize_net();
> +	synchronize_net();

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
