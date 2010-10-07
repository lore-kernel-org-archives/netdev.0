From: Bernard Metzler <BMT@zurich.ibm.com>
Subject: Re: [PATCH] SIW: Queue pair
Date: Thu, 7 Oct 2010 11:21:05 +0200
Message-ID: <OFB2B4DC29.734DA538-ONC12577B5.00304CFF-C12577B5.00335EA8@ch.ibm.com>
References: <AANLkTimM3Lpmt3JLgbCtuCjqFjNb8AkvBpdzpN7Sx978@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma@vger.kernel.org, linux-rdma-owner@vger.kernel.org,
	netdev@vger.kernel.org
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:58277 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812Ab0JGJVI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 05:21:08 -0400
In-Reply-To: <AANLkTimM3Lpmt3JLgbCtuCjqFjNb8AkvBpdzpN7Sx978@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



linux-rdma-owner@vger.kernel.org wrote on 10/06/2010 07:57:29 PM:

> On Tue, Oct 5, 2010 at 8:55 AM, Bernard Metzler <bmt@zurich.ibm.com>
wrote:
> >
> > [ ... ]
> > +int
> > +siw_qp_modify(struct siw_qp *qp, struct siw_qp_attrs *attrs,
> > + =A0 =A0 =A0 =A0 =A0 =A0 enum siw_qp_attr_mask mask)
> > +{
> > [ ... ]
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SIW_QP_STATE_ERROR:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 siw_rq_flush(qp);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qp->attrs.state =3D S=
IW_QP_STATE_ERROR;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 drop_conn =3D 1;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> At least for InfiniBand when the state of a queue pair is changed to
> Error, work requests must be completed in error. The above code just
> flushes pending work requests. That doesn't look correct to me.
>
> A quote from the InfiniBand Architecture Specification, table 91, QP
> State Transition Properties:
>
> Any state to Reset: QP attributes are reset to the same values after
> the QP was created. Outstanding Work Requests are removed from the
> queues without notifying the Consumer.
>
right. i was trying to follow the verbs specification, which makes the
same statement - see sec. 6.2.4 of the Hilland vers:

The following is done on entry into the Error state:

   *   The RI MUST flush any incomplete WRs on the SQ or RQ. All WQEs
       on the SQ and RQ, except for the WQE that caused the error (if
       any), MUST be returned with the Flushed Error Completion Status
       through the Completion Queue associated with the WQ.

following that, siw_rq_flush() flushes to the CQ. so, i think, we are
in sync here (the code flushes only the RQ to the CQ here, since we com=
e
from IDLE or RTR, which must not have anything on the SQ).


thanks,
bernard.

