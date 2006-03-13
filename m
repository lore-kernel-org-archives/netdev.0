From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [PATCH 5/6 v2] IB: IP address based RDMA connection manager
Date: Mon, 13 Mar 2006 09:11:34 -0800
Message-ID: <ORSMSX401FRaqbC8wSA0000001e__49318.5393316255$1142269988$gmane$org@orsmsx401.amr.corp.intel.com>
References: <adabqwafizj.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<openib-general@openib.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751511AbWCMRLj@vger.kernel.org>
To: "'Roland Dreier'" <rdreier@cisco.com>
In-Reply-To: <adabqwafizj.fsf@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +static void cma_detach_from_dev(struct rdma_id_private *id_priv)
> > +{
> > +	list_del(&id_priv->list);
> > +	if (atomic_dec_and_test(&id_priv->cma_dev->refcount))
> > +		wake_up(&id_priv->cma_dev->wait);
> > +	id_priv->cma_dev = NULL;
> > +}
>
>doesn't need to do atomic_dec_and_test(), because it is never dropping
>the last reference to id_priv (and in fact if it was, the last line
>would be a use-after-free bug).

It's dropping the reference on cma_dev, as opposed to id_priv.

- Sean
