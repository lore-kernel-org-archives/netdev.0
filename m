From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: [PATCH] SIW: User interface
Date: Tue, 05 Oct 2010 09:17:34 -0500
Message-ID: <4CAB337E.1040205@opengridcomputing.com>
References: <1286261647-5139-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1286261647-5139-1-git-send-email-bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/05/2010 01:54 AM, Bernard Metzler wrote:


<snip>

> +
> +/*
> + * siw_post_send()
> + *
> + * Post a list of S-WR's to a SQ.
> + *
> + * @ofa_qp:	OFA QP contained in siw QP
> + * @wr:		Null terminated list of user WR's
> + * @bad_wr:	Points to failing WR in case of synchronous failure.
> + */
> +int siw_post_send(struct ib_qp *ofa_qp, struct ib_send_wr *wr,
> +		  struct ib_send_wr **bad_wr)
> +{
> +	struct siw_wqe	*wqe = NULL;
> +	struct siw_qp	*qp = siw_qp_ofa2siw(ofa_qp);
> +
> +	unsigned long flags;
> +	int rv = 0;
> +
> +	dprint(DBG_WR|DBG_TX, "(QP%d): state=%d\n",
> +		QP_ID(qp), qp->attrs.state);
> +
> +	/*
> +	 * Acquire QP state lock for reading. The idea is that a
> +	 * user cannot move the QP out of RTS during TX/RX processing.
> +	 */
> +	down_read(&qp->state_lock);
> +
>    

I don't think you can use a rw_semaphore here because it potentially can 
block.  You cannot block/sleep in the post_send/post_recv (and some 
other) RDMA provider functions.  See 
Documentation/infiniband/core_locking.txt.


Steve.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
