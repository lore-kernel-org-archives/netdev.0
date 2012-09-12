From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv4] virtio-spec: virtio network device multiqueue support
Date: Wed, 12 Sep 2012 20:11:23 +0100
Message-ID: <1347477083.2580.19.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120909130308.GA3471@redhat.com>
	<878vcifwxi.fsf@rustcorp.com.au> <20120910061629.GC16819@redhat.com>
	<20120910062738.GA17331@redhat.com> <20120910063346.GA17338@redhat.com>
	<504DC831.1000709@redhat.com> <87har3dc4o.fsf@rustcorp.com.au>
	<20120912075737.GA30455@redhat.com>
	<CA+mtBx9NB=t=3YAB=MdRY_6hMe9J=z4U9o-pPe3iYfmxkeKJRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, pbonzini@redhat.com
To: Tom Herbert <therbert@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CA+mtBx9NB=t=3YAB=MdRY_6hMe9J=z4U9o-pPe3iYfmxkeKJRw@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-12 at 07:40 -0700, Tom Herbert wrote:
> On Wed, Sep 12, 2012 at 12:57 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Wed, Sep 12, 2012 at 03:19:11PM +0930, Rusty Russell wrote:
[...]
> >> Perhaps Tom can explain how we avoid out-of-order receive for the
> >> accelerated RFS case?  It's not clear to me, but we need to be able to
> >> do that for virtio-net if it implements accelerated RFS.
> >
> AFAIK ooo RX is still possible with accelerated RFS.  We have an
> algorithm that prevents this for RFS by deferring a migration to a new
> queue as long as it's possible that a flow might have outstanding
> packets on the old queue.  I suppose this could be implemented in the
> device for the HW queues, but I don't think it would be easy to cover
> all cases where packets were already in transit to the host or other
> cases where host and device queues are out of sync.
[...]

Yes, I couldn't see any way to eliminate the possibility of OOO.  The
software queue check in RFS should redirect the flow only when it is new
or has had an idle period, when I hope only a few packets will be
received before we send some kind of response (transport or application
layer ACK).  So I think that OOO is not that likely in practice, but I
don't have the evidence to back that up.

If the filter update latency is high enough that a response can overtake
the filter update, there may be more of a problem.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
