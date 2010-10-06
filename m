From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [PATCH] SIW: Queue pair
Date: Wed, 6 Oct 2010 19:57:29 +0200
Message-ID: <AANLkTimM3Lpmt3JLgbCtuCjqFjNb8AkvBpdzpN7Sx978@mail.gmail.com>
References: <1286261719-5197-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1286261719-5197-1-git-send-email-bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 5, 2010 at 8:55 AM, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> wr=
ote:
>
> [ ... ]
> +int
> +siw_qp_modify(struct siw_qp *qp, struct siw_qp_attrs *attrs,
> + =A0 =A0 =A0 =A0 =A0 =A0 enum siw_qp_attr_mask mask)
> +{
> [ ... ]
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SIW_QP_STATE_ERROR:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 siw_rq_flush(qp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qp->attrs.state =3D SIW=
_QP_STATE_ERROR;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 drop_conn =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;

At least for InfiniBand when the state of a queue pair is changed to
Error, work requests must be completed in error. The above code just
flushes pending work requests. That doesn't look correct to me.

A quote from the InfiniBand Architecture Specification, table 91, QP
State Transition Properties:

Any state to Reset: QP attributes are reset to the same values after
the QP was created. Outstanding Work Requests are removed from the
queues without notifying the Consumer.

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
