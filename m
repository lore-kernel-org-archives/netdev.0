From: "Felix Marti" <felix@chelsio.com>
Subject: Re: [PATCH  v4 01/13] Linux RDMA Core Changes
Date: Fri, 5 Jan 2007 09:32:19 -0800
Message-ID: <8A71B368A89016469F72CD08050AD334F3BE50@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
Content-class: urn:content-classes:message
To: "Steve Wise" <swise@opengridcomputing.com>,
	"Roland Dreier" <rdreier@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: openib-general-bounces@openib.org [mailto:openib-general-
> bounces@openib.org] On Behalf Of Steve Wise
> Sent: Friday, January 05, 2007 6:22 AM
> To: Roland Dreier
> Cc: linux-kernel@vger.kernel.org; openib-general@openib.org;
> netdev@vger.kernel.org
> Subject: Re: [openib-general] [PATCH v4 01/13] Linux RDMA Core Changes
> 
> On Thu, 2007-01-04 at 13:34 -0800, Roland Dreier wrote:
> > OK, I'm back from vacation today.
> >
> > Anyway I don't have a definitive statement on this right now.  I
guess
> > I agree that I don't like having an extra parameter to a function
that
> > should be pretty fast (although req notify isn't quite as hot as
> > something like posting a send request or polling a cq), given that
it
> > adds measurable overhead.  (And I am surprised that the overhead is
> > measurable, since 3 arguments still fit in registers, but OK).
> >
> > I also agree that adding an extra entry point just to pass in the
user
> > data is ugly, and also racy.
> >
> > Giving the kernel driver a pointer it can read seems OK I guess,
> > although it's a little ugly to have a backdoor channel like that.
> >
> 
> Another alternative is for the cq-index u32 memory to be allocated by
> the kernel and mapped into the user process.  So the lib can
read/write
> it, and the kernel can read it directly.  This is the fastest way
> perfwise, but I didn't want to do it because of the page granularity
of
> mapping.  IE it would require a page of address space (and backing
> memory I guess) just for 1 u32.  The CQ element array memory is
already
> allocated this way (and its DMA coherent too), but I didn't want to
> overload that memory with this extra variable either.  Mapping just
> seemed ugly and wasteful to me.
> 
> So given 3 approaches:
> 
> 1) allow user data to be passed into ib_req_notify_cq() via the
standard
> uverbs mechanisms.
> 
> 2) hide this in the chelsio driver and have the driver copyin the info
> directly.
> 
> 3) allocate the memory for this in the kernel and map it to the user
> process.
> 
> I chose 1 because it seemed the cleanest from an architecture point of
> view and I didn't think it would impact performance much.

[Felix Marti] In addition, is arming the CQ really in the performance
path? - Don't apps poll the CQ as long as there are pending CQEs and
only arm the CQ for notification once there is nothing left to do? If
this is the case, it would mean that we waste a few cycles 'idle'
cycles. Steve, next to the micro benchmark that you did, did you run any
performance benchmark that actually moves traffic? If so, did you see a
difference in performance?

> 
> 
> Steve.
> 
> 
> 
> 
> 
> _______________________________________________
> openib-general mailing list
> openib-general@openib.org
> http://openib.org/mailman/listinfo/openib-general
> 
> To unsubscribe, please visit
http://openib.org/mailman/listinfo/openib-general
