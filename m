From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH v5 1/2] iWARP Connection Manager.
Date: Wed, 30 Aug 2006 10:35:30 -0700
Message-ID: <adafyfem8il.fsf@cisco.com>
References: <20060803210238.16228.47335.stgit@dell3.ogc.int>
	<20060803210240.16228.18429.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:34596 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1751170AbWH3Rfd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 13:35:33 -0400
To: Steve Wise <swise@opengridcomputing.com>, tom@opengridcomputing.com
In-Reply-To: <20060803210240.16228.18429.stgit@dell3.ogc.int> (Steve Wise's message of "Thu, 03 Aug 2006 16:02:40 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, getting closer to finishing the merge...

anyway, why is iw_cm_private.h in include/rdma where it is visible
everywhere?  As far as I can tell drivers/infiniband/core/iwcm.c is
the only place it's included.  So why not just put this stuff in
drivers/infiniband/core/iwcm.h and do

	#include "iwcm.h"

Or the file is small enough that maybe it's simpler just to stuff this
at the top of iwcm.c and kill the include entirely?

 - R.

 > --- /dev/null
 > +++ b/include/rdma/iw_cm_private.h
 > @@ -0,0 +1,63 @@
 > +#ifndef IW_CM_PRIVATE_H
 > +#define IW_CM_PRIVATE_H
 > +
 > +#include <rdma/iw_cm.h>
 > +
 > +enum iw_cm_state {
 > +	IW_CM_STATE_IDLE,             /* unbound, inactive */
 > +	IW_CM_STATE_LISTEN,           /* listen waiting for connect */
 > +	IW_CM_STATE_CONN_RECV,        /* inbound waiting for user accept */
 > +	IW_CM_STATE_CONN_SENT,        /* outbound waiting for peer accept */
 > +	IW_CM_STATE_ESTABLISHED,      /* established */
 > +	IW_CM_STATE_CLOSING,	      /* disconnect */
 > +	IW_CM_STATE_DESTROYING        /* object being deleted */
 > +};
 > +
 > +struct iwcm_id_private {
 > +	struct iw_cm_id	id;
 > +	enum iw_cm_state state;
 > +	unsigned long flags;
 > +	struct ib_qp *qp;
 > +	struct completion destroy_comp;
 > +	wait_queue_head_t connect_wait;
 > +	struct list_head work_list;
 > +	spinlock_t lock;
 > +	atomic_t refcount;
 > +	struct list_head work_free_list;
 > +};
 > +#define IWCM_F_CALLBACK_DESTROY   1
 > +#define IWCM_F_CONNECT_WAIT       2
 > +
 > +#endif /* IW_CM_PRIVATE_H */
