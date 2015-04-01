From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and
 cap_sa(), for sa-check
Date: Tue, 31 Mar 2015 19:31:35 -0600
Message-ID: <20150401013135.GA29331@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
 <55157B43.6060507@profitbricks.com>
 <1427732191.21101.201.camel@redhat.com>
 <55197CDB.3040105@profitbricks.com>
 <1427734923.21101.227.camel@redhat.com>
 <20150331231202.GA20094@obsidianresearch.com>
 <20150401005113.GA15327@phlsvsds.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <mata
To: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150401005113.GA15327-W4f6Xiosr+yv7QzWx2u06xL4W9x8LtSr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 31, 2015 at 08:51:13PM -0400, ira.weiny wrote:

> > Going forward we want to NAK stuff like this:
> > 
> >   if (rdma_ib_mgmt() || rdma_opa_mgmt())
> >   if (has_sa() || has_opa_foobar())
> 
> I'm confused.
> 
> Is the idea that you would NAK has_sa but be in favor of has_ib_sa?

It is the || I don't want to see. Feature tests should be one thing.

> I believe it is reasonable to flag OPA MAD support as a feature set through a
> single bit.  From this the MAD stack can know if OPA MAD base/class versions
> are allowed (or treated differently from future IB versions) and if it should
> processing OPA SM Class DR MADs differently.  I don't want devices to be
> required to supply a list of MAD Base/Class Versions they support.

That seems reasonable, but we'd gain a is_ib_smp and is_opa_smp test
to do that.

> For example, the MAD size is more generally (and perhaps better) communicated
> via an actual mad_size attribute rather than as part of the OPA MAD feature
> set.

Start with a bit and change when that makes no sense, MTUs as ints
make sense.

> Another example is the question of is it appropriate to wrap up the single READ
> SGL entry support within the "is iwarp" flag?

Again, stick with a single bit test until a HW vendors needs more,
then someone can clean it. At least they now know what to clean and
why.

Remember, this is in the kernel, we can change it when it outlives its
life.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
