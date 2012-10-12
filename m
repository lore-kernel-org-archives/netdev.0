From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Fri, 12 Oct 2012 13:52:58 +0200
Message-ID: <20121012135258.75ca3310@BR9GNB5Z>
References: <506C192E.5060700@redhat.com> <87bogj2j1b.fsf@rustcorp.com.au>
	<506D3610.7000103@redhat.com> <87ipaq1jtt.fsf@rustcorp.com.au>
	<506D8DD5.20904@redhat.com>
	<87391t1nkq.fsf__40391.6521034718$1349505001$gmane$org@rustcorp.com.au>
	<507029EB.2050405@redhat.com> <878vbg8cma.fsf@rustcorp.com.au>
	<5073D1D8.3060905@redhat.com> <87k3ux98oc.fsf@rustcorp.com.au>
	<20121011110430.GF5552@redhat.com> <87wqyw63et.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Sasha Levin <levinsasha928@gmail.com>,
	Paolo Bonzini <pbonzini@redhat.com>, avi@redhat.com,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87wqyw63et.fsf@rustcorp.com.au>
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

On Fri, 12 Oct 2012 09:07:46 +1030
Rusty Russell <rusty@rustcorp.com.au> wrote:

> "Michael S. Tsirkin" <mst@redhat.com> writes:
> > On Thu, Oct 11, 2012 at 10:33:31AM +1030, Rusty Russell wrote:
> >> OK.  Well, Anthony wants qemu to be robust in this regard, so I am
> >> tempted to rework all the qemu drivers to handle arbitrary layouts.
> >> They could use a good audit anyway.
> >
> > I agree here. Still trying to understand whether we can agree to use
> > a feature bit for this, or not.
> 
> I'd *like* to imply it by the new PCI layout, but if it doesn't work
> we'll add a new feature bit.
> 
> I'm resisting a feature bit, since it constrains future implementations
> which could otherwise assume it.
> 
> >> This would become a glaring exception, but I'm tempted to fix it to 32
> >> bytes at the same time as we get the new pci layout (ie. for the virtio
> >> 1.0 spec).
> >
> > But this isn't a virtio-pci only issue, is it?
> > qemu has s390 bus with same limmitation.
> > How can we tie it to pci layout?
> 
> They can use a transport feature if they need to, of course.  But
> perhaps the timing with ccw will coincide with the fix, in which they
> don't need to, but it might be a bit late.
> 
> Cornelia?

My virtio-ccw host code is still going through a bit of rework, so it
might well go in after the fix.

There's also the existing (non-spec'ed) s390-virtio transport. While it
will likely be deprecated sometime in the future, it should probably
get a feature bit for consistency's sake.

> 
> Cheers,
> Rusty.
> 
