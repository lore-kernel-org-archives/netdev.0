From: <Parav.Pandit@Emulex.Com>
Subject: RE: [PATCH 4/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 12:09:09 -0700
Message-ID: <88B766C272F2C64B944B21AD078333151C964A63FB@EXMAIL.ad.emulex.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-2-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-3-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-4-git-send-email-parav.pandit@emulex.com>
 <a5e59a7c-d6ff-4c78-89a7-fad7492260b0@exht1.ad.emulex.com>
 <CAL1RGDWRm7GVCBgAdSvAt72WQAP4a-1xa18Hk-rFjEfKDEHZNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>
To: <roland@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:34779 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755045Ab2CUTJc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 15:09:32 -0400
In-Reply-To: <CAL1RGDWRm7GVCBgAdSvAt72WQAP4a-1xa18Hk-rFjEfKDEHZNg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Roland Dreier [mailto:roland@purestorage.com]
> Sent: Wednesday, March 21, 2012 10:04 PM
> To: Pandit, Parav
> Cc: linux-rdma@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [PATCH 4/9] ocrdma: Driver for Emulex OneConnect RDMA
> adapter
>=20
> > +int ocrdma_qp_state_machine(struct ocrdma_qp *qp, enum ib_qp_state
> > +new_ib_state,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum ib_qp_st=
ate *old_ib_state) {
> > + =A0 =A0 =A0 unsigned long flags;
> > + =A0 =A0 =A0 int status =3D 0;
> > + =A0 =A0 =A0 enum ocrdma_qp_state new_state;
> > + =A0 =A0 =A0 new_state =3D get_ocrdma_qp_state(new_ib_state);
> > +
> > + =A0 =A0 =A0 /* sync with wqe and rqe posting */
> > + =A0 =A0 =A0 spin_lock_irqsave(&qp->q_lock, flags);
> > +
> > + =A0 =A0 =A0 if (old_ib_state)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *old_ib_state =3D get_ibqp_state(qp->=
state);
> > + =A0 =A0 =A0 if (new_state =3D=3D qp->state) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&qp->q_lock, f=
lags);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> > + =A0 =A0 =A0 }
> > +
> > + =A0 =A0 =A0 switch (qp->state) {
> > + =A0 =A0 =A0 case OCRDMA_QPS_RST:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (new_state) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_RST:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_INIT:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -EINVAL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 case OCRDMA_QPS_INIT:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* qps: INIT->XXX */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (new_state) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_INIT:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_RTR:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_ERR:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ocrdma_flush_qp(qp);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -EINVAL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 case OCRDMA_QPS_RTR:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* qps: RTS->XXX */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (new_state) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_RTS:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_ERR:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ocrdma_flush_qp(qp);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -EINVAL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 case OCRDMA_QPS_RTS:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* qps: RTS->XXX */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (new_state) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_SQD:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_SQE:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_ERR:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ocrdma_flush_qp(qp);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -EINVAL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 case OCRDMA_QPS_SQD:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* qps: SQD->XXX */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (new_state) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_RTS:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_SQE:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_ERR:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -EINVAL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 case OCRDMA_QPS_SQE:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (new_state) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_RTS:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_ERR:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -EINVAL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 case OCRDMA_QPS_ERR:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* qps: ERR->XXX */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (new_state) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case OCRDMA_QPS_RST:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -EINVAL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 default:
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -EINVAL;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 };
> > + =A0 =A0 =A0 if (!status)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qp->state =3D new_state;
> > +
> > + =A0 =A0 =A0 spin_unlock_irqrestore(&qp->q_lock, flags);
> > + =A0 =A0 =A0 return status;
> > +}
>=20
> The switch statement here seems to largely reimpliment
> ib_modify_qp_is_ok() (which is exported from the rdma midlayer).  Is =
there
> some reason that doesn't work for your driver?  I'd rather fix / gene=
ralize the
> core helper function instead of having something mostly duplicate in =
a
> hardware driver.
Yes. Driver needs to put QP to flush state. So that appropriate CQEs ca=
n be returned during poll_cq() phase.
So state machine is implemented above.
