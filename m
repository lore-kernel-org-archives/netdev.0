From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [SCSI] cxgb3i: convert cdev->l2opt to use rcu to prevent NULL
 dereference (v2)
Date: Mon, 26 Sep 2011 09:31:15 -0500
Message-ID: <1317047476.9560.0.camel@dabdike>
References: <20110926134048.GA10999@longonot.mountain>
	 <20110926142052.GA18283@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20110926142052.GA18283@hmsreliant.think-freely.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-09-26 at 10:20 -0400, Neil Horman wrote:
> On Mon, Sep 26, 2011 at 04:40:48PM +0300, Dan Carpenter wrote:
> > Hi Neil,
> > 
> > c98bc57ee65b6 "[SCSI] cxgb3i: convert cdev->l2opt to use rcu to
> > prevent NULL dereference (v2)" from linux-next introduces a usinging
> > uninitialized variable bug.
> > 
> >  struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
> >                              struct net_device *dev)
> >  {
> > -       struct l2t_entry *e;
> > -       struct l2t_data *d = L2DATA(cdev);
> > +       struct l2t_entry *e = NULL;
> > +       struct l2t_data *d;
> >         u32 addr = *(u32 *) neigh->primary_key;
> >         int ifidx = neigh->dev->ifindex;
> >         int hash = arp_hash(addr, ifidx, d);
> >                                          ^
> > Uninitialized variable.
> > 
> >         struct port_info *p = netdev_priv(dev);
> >         int smt_idx = p->port_id;
> >  
> > +       rcu_read_lock();
> > +       d = L2DATA(cdev);
> > +       if (!d)
> > +               goto done_rcu;
> > +
> > 
> > regards,
> > dan carpenter
> > 
> 
> Yup, thanks, you need this to9 fix the uninitalized var.

I rolled this into the original.

James


