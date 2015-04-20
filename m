From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v2 01/11] RDMA/CMA: Mark IPv4 addresses correctly when
 the listener is IPv6
Date: Mon, 20 Apr 2015 10:41:40 -0600
Message-ID: <20150420164140.GC7676@obsidianresearch.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
 <1429520622-10303-2-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1429520622-10303-2-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 20, 2015 at 12:03:32PM +0300, Haggai Eran wrote:
> From: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> When accepting a new connection with the listener being IPv6, the
> family of the new connection is set as IPv6. This causes cma_zero_addr
> function to return true on an non-zero address. As a result, the wrong
> code path is taken. This causes the connection request to be rejected,
> as the RDMA-CM code looks for the wrong type of device.

This description doesn't really make sense as to what the problem is.

> @@ -866,12 +866,12 @@ static void cma_save_ip4_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_i
>  
>  	listen4 = (struct sockaddr_in *) &listen_id->route.addr.src_addr;
>  	ip4 = (struct sockaddr_in *) &id->route.addr.src_addr;
> -	ip4->sin_family = listen4->sin_family;
> +	ip4->sin_family = AF_INET;

If listen_id->route.addr.src_addr.ss_family != AF_INET then it is
invalid to cast to sockaddr_in.

So listen4->sin_family MUST be AF_INET or this function MUST NOT be
called.

Forcing to AF_INET cannot be correct here.

What does this patch have to do with this series?

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
