From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 3/3] bnx2i: Add bnx2i iSCSI driver.
Date: Fri, 23 May 2008 13:23:17 -0700
Message-ID: <ada8wy07osq.fsf@cisco.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com>
	<1211418386-18203-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, michaelc@cs.wisc.edu, anilgv@broadcom.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1211418386-18203-4-git-send-email-mchan@broadcom.com> (Michael
	Chan's message of "Wed, 21 May 2008 18:06:26 -0700")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael, I was reading over the driver to try and figure out how you
handle allocating source ports for the offloaded TCP connections you
make so that they don't collide with the main network stack.  It looks
like you have:

 > +/**
 > + * bnx2i_alloc_tcp_port - allocates a tcp port from the free list
 > + *
 > + * Assumes this function is called with 'bnx2i_resc_lock' held.
 > + */
 > +static u16 bnx2i_alloc_tcp_port(void)

that has some failure code:

 > +	if (!tcp_port) {
 > +		printk(KERN_ERR "bnx2i: run 'bnx2id' to alloc tcp ports\n");

but I don't know what bnx2id is?

and I didn't see anywhere that bnx2i_get_tcp_port_requirements() is
actually called, and it's not exported?

 > +/**
 > + * bnx2i_get_tcp_port_requirements - returns num tcp ports to alloc/bind
 > + *
 > + * driver returns the number of TCP ports to be allocated/bound by 'bnx2id'
 > + *	daemon. Return value of '0' means driver has everything to support
 > + *	max iscsi connections on enumerated NX2 devices
 > + */
 > +int bnx2i_get_tcp_port_requirements(void)
