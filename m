From: "Anil Veerabhadrappa" <anilgv@broadcom.com>
Subject: Re: [PATCH 3/3] bnx2i: Add bnx2i iSCSI driver.
Date: Fri, 23 May 2008 14:42:49 -0700
Message-ID: <1211578969.26900.5.camel@dhcp-10-13-110-217.broadcom.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com>
 <1211418386-18203-4-git-send-email-mchan@broadcom.com>
 <ada8wy07osq.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>, davem@davemloft.net,
	michaelc@cs.wisc.edu, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <ada8wy07osq.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-05-23 at 13:23 -0700, Roland Dreier wrote: 
> Hi Michael, I was reading over the driver to try and figure out how you
> handle allocating source ports for the offloaded TCP connections you
> make so that they don't collide with the main network stack.  It looks
> like you have:
> 
>  > +/**
>  > + * bnx2i_alloc_tcp_port - allocates a tcp port from the free list
>  > + *
>  > + * Assumes this function is called with 'bnx2i_resc_lock' held.
>  > + */
>  > +static u16 bnx2i_alloc_tcp_port(void)
> 
> that has some failure code:
> 
>  > +	if (!tcp_port) {
>  > +		printk(KERN_ERR "bnx2i: run 'bnx2id' to alloc tcp ports\n");
> 
> but I don't know what bnx2id is?

'bnx2id' is the user component in this solution. bnx2id daemon uses
socket calls to bind tcp ports in high range and hands them over to
driver. This is how iscsi driver tries to solve tcp port collision
issue. User daemon communicates with the driver using sysfs and tcp port
related functions are bnx2i_read_tcp_portd_*/bnx2i_write_tcp_portd_*
(reference: bnx2i_sysfs.c)

> 
> and I didn't see anywhere that bnx2i_get_tcp_port_requirements() is
> actually called, and it's not exported?
> 
>  > +/**
>  > + * bnx2i_get_tcp_port_requirements - returns num tcp ports to alloc/bind
>  > + *
>  > + * driver returns the number of TCP ports to be allocated/bound by 'bnx2id'
>  > + *	daemon. Return value of '0' means driver has everything to support
>  > + *	max iscsi connections on enumerated NX2 devices
>  > + */
>  > +int bnx2i_get_tcp_port_requirements(void)
> 
Actually this logic was simplified by adding a new member,
'num_required' to 'tcp_port_mgmt' structure. This call is no more
required, will remove bnx2i_get_tcp_port_requirements() in the next
driver revision

