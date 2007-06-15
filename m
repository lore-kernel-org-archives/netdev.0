From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive v2
Date: Fri, 15 Jun 2007 13:44:40 +0400
Message-ID: <20070615094440.GA26221@2ka.mipt.ru>
References: <20070611115926.GB18832@kernel.dk> <20070612181717.GA1600@2ka.mipt.ru> <20070612181731.GQ18832@kernel.dk> <20070613080103.GA24701@2ka.mipt.ru> <20070614115720.GA14840@2ka.mipt.ru> <20070614115902.GG6149@kernel.dk> <20070615080618.GA22234@2ka.mipt.ru> <20070615084318.GP6149@kernel.dk> <20070615091445.GA27451@2ka.mipt.ru> <20070615093429.GQ6149@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35492 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750930AbXFOJos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 05:44:48 -0400
Content-Disposition: inline
In-Reply-To: <20070615093429.GQ6149@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 15, 2007 at 11:34:30AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > Both spd->nr_pages and page_nr are equal to 1. When spd->nr_pages
> > was 2 there was only 1 free slot in pipe_buffer.
> 
> Ah duh, indeed, it is a dumb bug indeed. This should work.

Yep, this one works too.

> diff --git a/fs/splice.c b/fs/splice.c
> index 89871c6..5327cbf 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -172,6 +172,7 @@ static const struct pipe_buf_operations user_page_pipe_buf_ops = {
>  ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
>  		       struct splice_pipe_desc *spd)
>  {
> +	unsigned int spd_pages = spd->nr_pages;
>  	int ret, do_wakeup, page_nr;
>  
>  	ret = 0;
> @@ -252,7 +253,7 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
>  		}
>  	}
>  
> -	while (page_nr < spd->nr_pages)
> +	while (page_nr < spd_pages)
>  		spd->spd_release(spd, page_nr++);
>  
>  	return ret;
> 
> -- 
> Jens Axboe

-- 
	Evgeniy Polyakov
