From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCH v2 11/17] IB/Verbs: Reform link_layer_show() and ib_uverbs_query_port()
Date: Tue, 7 Apr 2015 13:56:47 -0500
Message-ID: <005e01d07164$9954e390$cbfeaab0$@opengridcomputing.com>
References: <5523CCD5.6030401@profitbricks.com> <5523CF30.7000608@profitbricks.com> <1828884A29C6694DAF28B7E6B8A82373A8FBE2FA@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "'Hal Rosenstock'" <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"'Tom Tucker'" <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	"'Hoang-Nam Nguyen'" <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	"'Christoph Raisch'" <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	"'infinipath'" <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"'Eli Cohen'" <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"'Latif, Faisal'" <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"'Upinder Malhi'" <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"'Trond Myklebust'" <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"'J. Bruce Fields'" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"'David S. Miller'" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"'Weiny, Ira'" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"'PJ Waskiewicz'" <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	"'Nikolova, Tatyana E'" <tatyana.e.nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"'Or Gerlitz'" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"'Jack Morgenstein'" <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	"'Haggai Eran'" <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"'Ilya Nelkenbaum'" <ilyan-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"'Yann Droneaud'" <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	"'Bart Van Assche'" <bvanassche-HInyCGIudOg@public.gmane.org>,
	"'Sha
To: "'Hefty, Sean'" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"'Michael Wang'" <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	"'Roland Dreier'" <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FBE2FA-P5GAC/sN6hkd3b2yrw5b5LfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Content-Language: en-us
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> 
> > diff --git a/drivers/infiniband/core/sysfs.c
> > b/drivers/infiniband/core/sysfs.c
> > index cbd0383..aa53e40 100644
> > --- a/drivers/infiniband/core/sysfs.c
> > +++ b/drivers/infiniband/core/sysfs.c
> > @@ -248,14 +248,10 @@ static ssize_t phys_state_show(struct ib_port *p,
> > struct port_attribute *unused,
> >  static ssize_t link_layer_show(struct ib_port *p, struct port_attribute
> > *unused,
> >  			       char *buf)
> >  {
> > -	switch (rdma_port_get_link_layer(p->ibdev, p->port_num)) {
> > -	case IB_LINK_LAYER_INFINIBAND:
> > +	if (rdma_transport_ib(p->ibdev, p->port_num))
> >  		return sprintf(buf, "%s\n", "InfiniBand");
> > -	case IB_LINK_LAYER_ETHERNET:
> > +	else
> >  		return sprintf(buf, "%s\n", "Ethernet");
> > -	default:
> > -		return sprintf(buf, "%s\n", "Unknown");
> > -	}
> >  }
> >
> >  static PORT_ATTR_RO(state);
> > diff --git a/drivers/infiniband/core/uverbs_cmd.c
> > b/drivers/infiniband/core/uverbs_cmd.c
> > index a9f0489..3eb6eb5 100644
> > --- a/drivers/infiniband/core/uverbs_cmd.c
> > +++ b/drivers/infiniband/core/uverbs_cmd.c
> > @@ -515,8 +515,10 @@ ssize_t ib_uverbs_query_port(struct ib_uverbs_file
> > *file,
> >  	resp.active_width    = attr.active_width;
> >  	resp.active_speed    = attr.active_speed;
> >  	resp.phys_state      = attr.phys_state;
> > -	resp.link_layer      = rdma_port_get_link_layer(file->device-
> > >ib_dev,
> > -							cmd.port_num);
> > +	resp.link_layer      = rdma_transport_ib(file->device->ib_dev,
> > +							cmd.port_num) ?
> > +			       IB_LINK_LAYER_INFINIBAND :
> > +			       IB_LINK_LAYER_ETHERNET;
> >
> >  	if (copy_to_user((void __user *) (unsigned long) cmd.response,
> >  			 &resp, sizeof resp))
> 
> Both of the above check the transport in order to determine the link layer.
> 
> These values are exposed to user space.  Does anyone know what link layer iWarp returns to user space?

Ethernet:

t4:~ # ibv_devinfo -d cxgb4_0|grep link_layer
                        link_layer:             Ethernet
                        link_layer:             Ethernet

Steve.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
