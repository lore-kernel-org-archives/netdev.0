From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost-net: fix vq_memory_access_ok error checking
Date: Tue, 13 Apr 2010 18:02:17 +0300
Message-ID: <20100413150217.GA7871@redhat.com>
References: <20100413150121.GB7716@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Juan Quintela <quintela@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Laurent Chavey <chavey@google.com>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Dike <jdike@addtoit.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100413150121.GB7716@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 13, 2010 at 06:01:21PM +0300, Michael S. Tsirkin wrote:
> On Wed, Apr 07, 2010 at 09:59:10AM -0400, Jeff Dike wrote:
> > vq_memory_access_ok needs to check whether mem == NULL
> > 
> > Signed-off-by: Jeff Dike <jdike@linux.intel.com>
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> This was already queued by me, you do not need to
> fill Dave's inbox with vhost patches.

This was sent in error, please ignore.
Sorry about the noise.

> > ---
> >  drivers/vhost/vhost.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > index 7bd7a1e..b8e1127 100644
> > --- a/drivers/vhost/vhost.c
> > +++ b/drivers/vhost/vhost.c
> > @@ -235,6 +235,10 @@ static int vq_memory_access_ok(void __user *log_base, struct vhost_memory *mem,
> >  			       int log_all)
> >  {
> >  	int i;
> > +
> > +        if (!mem)
> > +                return 0;
> > +
> >  	for (i = 0; i < mem->nregions; ++i) {
> >  		struct vhost_memory_region *m = mem->regions + i;
> >  		unsigned long a = m->userspace_addr;
> > -- 
> > 1.7.0.2.280.gc6f05
