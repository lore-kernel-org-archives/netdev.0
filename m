From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [Patch 3/3] IB/ib_cm: hang in cm_destroy_id during PCI error
 injection
Date: Wed, 23 Apr 2014 21:34:55 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373992F4867@ORSMSX109.amr.corp.intel.com>
References: <20140327142813.535289178@linux.vnet.ibm.com>
 <20140327142939.460692817@linux.vnet.ibm.com>
 <1828884A29C6694DAF28B7E6B8A82373992F353B@ORSMSX109.amr.corp.intel.com>
 <53580D42.1060201@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Carol Soto <clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	"roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53580D42.1060201-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > This is a device level event, not a port event.  The port_num value may
> not be valid.
> The first patch of the series(IB/mlx4: send a IB_EVENT_DEVICE_FATAL to
> users during PCI error injection), when mlx4 send the IB_EVENT_DEVICE_FATAL
> event I am passing the port number to that field so in that way I was
> able to make it work. Any other suggestions are welcome.

This would need to be done for all devices.

Converting this to a per port event requires multiple events per device, which would impact the user space ABI.  I think the patch itself needs to change to remove the per port association and operate at the device level, since it is really a device event. 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
