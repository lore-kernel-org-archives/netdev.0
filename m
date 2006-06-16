From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH v2 4/7] AMSO1100 Memory Management.
Date: Fri, 16 Jun 2006 09:20:31 -0500
Message-ID: <1150467631.29508.11.camel@stevo-desktop>
References: <20060607200646.9259.24588.stgit@stevo-desktop>
	 <20060607200655.9259.90768.stgit@stevo-desktop>
	 <20060608011744.1a66e85a.akpm@osdl.org>
	 <1150128349.22704.20.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, rdreier@cisco.com,
	mshefty@ichips.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:8028 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1751410AbWFPOUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2006 10:20:33 -0400
To: Tom Tucker <tom@opengridcomputing.com>
In-Reply-To: <1150128349.22704.20.camel@trinity.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 2006-06-12 at 11:05 -0500, Tom Tucker wrote:
> On Thu, 2006-06-08 at 01:17 -0700, Andrew Morton wrote:
> > On Wed, 07 Jun 2006 15:06:55 -0500
> > Steve Wise <swise@opengridcomputing.com> wrote:
> > 
> > > 
> > > +void c2_free(struct c2_alloc *alloc, u32 obj)
> > > +{
> > > +	spin_lock(&alloc->lock);
> > > +	clear_bit(obj, alloc->table);
> > > +	spin_unlock(&alloc->lock);
> > > +}
> > 
> > The spinlock is unneeded here.
> 
> Good point.
> 
> > 
> > 
> > What does all the code in this file do, anyway?  It looks totally generic
> > (and hence inappropriate for drivers/infiniband/hw/amso1100/) and somewhat
> > similar to idr trees, perhaps.
> > 
> 
> We mimicked the mthca driver. It may be code that should be replaced
> with Linux core services for new drivers. We'll investigate.
> 

The code in this file implements 2 sets of services:  

1) allocating unique qp identifiers (type integer).  This is the
c2_alloc struct and functions.

2) maintaining a sparsely allocated array of ptrs indexed by the qp
identifier.  This allows for quick mapping to the qp structure ptr given
the qp identifier.  This is the c2_array struct and functions.


I believe I can use an IDR tree to provide both of these services.


Steve.



