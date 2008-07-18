From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 22:35:50 +0400
Message-ID: <20080718183549.GA23263@2ka.mipt.ru>
References: <200807171633.49791.opurdila@ixiacom.com> <200807182004.44664.opurdila@ixiacom.com> <20080718175341.GA21496@2ka.mipt.ru> <200807182116.43451.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	axboe@kernel.dk
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759454AbYGRSgV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200807182116.43451.opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 18, 2008 at 09:16:43PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> tcp_read_sock
>  ... -> skb_splice_bits -> spd_fill_page; 
>   on return (spd->nr_page is 1 and pipe->nrbufs is 1)
>  ... -> skb_splice_bits -> spd_fill_page; 
>   on return (spd->nr_page is 1 and pipe->nrbufs is 2)
>  ... -> skb_splice_bits -> spd_fill_page; 
>   on return (spd->nr_page is 1 and pipe->nrbufs is 3)
> ...
> 
> and so on until pipe->nrbufs is 16. At than point, we will block in pipe_wait, 
> inside splice_to_pipe.

Seems that SPLICE_F_NONBLOCK check should be propagated from
tcp_splice_read() into skb_splice_bits(), and this flag is actually
there already in tss.flags.

-- 
	Evgeniy Polyakov
