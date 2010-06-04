From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Patch] infiniband: check local reserved ports
Date: Fri, 04 Jun 2010 09:53:30 +0800
Message-ID: <4C085C9A.30506@redhat.com>
References: <20100603083106.6047.7657.sendpatchset@localhost.localdomain> <ada1vcoqde3.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ada1vcoqde3.fsf-BjVyx320WGW9gfZ95n9DRSW4+XlvGpQz@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/04/10 00:39, Roland Dreier wrote:
>   >  Since Tetsuo's patch already got merged, now this is the missing part
>   >  for local port reservation.
>   >
>   >  Cc: Roland Dreier<rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
>   >  Cc: Tetsuo Handa<penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>
>   >  Signed-off-by: WANG Cong<amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>   >
>   >  ---
>   >  diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
>   >  index b930b81..7b89bab 100644
>   >  --- a/drivers/infiniband/core/cma.c
>   >  +++ b/drivers/infiniband/core/cma.c
>   >  @@ -1978,6 +1978,7 @@ static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
>   >   	rover = net_random() % remaining + low;
>   >   retry:
>   >   	if (last_used_port != rover&&
>   >  +	    !inet_is_reserved_local_port(rover)&&
>   >   	!idr_find(ps, (unsigned short) rover)) {
>   >   		int ret = cma_alloc_port(ps, id_priv, rover);
>   >   		/*
>
> Should this inet_is_reserved_local_port() test apply to all the "port
> spaces" that this code is handling?  I honestly am ignorant of the
> intended semantics of the new local_reserved_ports stuff, hence my question.
>

Yes, but I only found this case, is there any else?

Thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
