From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Thu, 11 Oct 2012 13:04:31 +0200
Message-ID: <20121011110430.GF5552@redhat.com>
References: <506C192E.5060700@redhat.com> <87bogj2j1b.fsf@rustcorp.com.au>
	<506D3610.7000103@redhat.com> <87ipaq1jtt.fsf@rustcorp.com.au>
	<506D8DD5.20904@redhat.com>
	<87391t1nkq.fsf__40391.6521034718$1349505001$gmane$org@rustcorp.com.au>
	<507029EB.2050405@redhat.com> <878vbg8cma.fsf@rustcorp.com.au>
	<5073D1D8.3060905@redhat.com> <87k3ux98oc.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Sasha Levin <levinsasha928@gmail.com>,
	Paolo Bonzini <pbonzini@redhat.com>, avi@redhat.com,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87k3ux98oc.fsf@rustcorp.com.au>
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

On Thu, Oct 11, 2012 at 10:33:31AM +1030, Rusty Russell wrote:
> Paolo Bonzini <pbonzini@redhat.com> writes:
> > Il 09/10/2012 06:59, Rusty Russell ha scritto:
> >> Paolo Bonzini <pbonzini@redhat.com> writes:
> >>> Il 05/10/2012 07:43, Rusty Russell ha scritto:
> >>>> That's good.  But virtio_blk's scsi command is insoluble AFAICT.  As I
> >>>> said to Anthony, the best rules are "always" and "never", so I'd really
> >>>> rather not have to grandfather that in.
> >>>
> >>> It is, but we can add a rule that if the (transport) flag
> >>> VIRTIO_RING_F_ANY_HEADER_SG is set, the cdb field is always 32 bytes in
> >>> virtio-blk.
> >> 
> >> Could we do that?  It's the cmd length I'm concerned about; is it always
> >> 32 in practice for some reason?
> >
> > It is always 32 or less except in very obscure cases that are pretty
> > much confined to iSCSI.  We don't care about the obscure cases, and the
> > extra bytes don't hurt.
> >
> > BTW, 32 is the default cdb_size used by virtio-scsi.
> >
> >> Currently qemu does:
> >> 
> >>     struct sg_io_hdr hdr;
> >>     memset(&hdr, 0, sizeof(struct sg_io_hdr));
> >>     hdr.interface_id = 'S';
> >>     hdr.cmd_len = req->elem.out_sg[1].iov_len;
> >>     hdr.cmdp = req->elem.out_sg[1].iov_base;
> >>     hdr.dxfer_len = 0;
> >> 
> >> If it's a command which expects more output data, there's no way to
> >> guess where the boundary is between that command and the data.
> >
> > Yep, so I understood the problem right.
> 
> OK.  Well, Anthony wants qemu to be robust in this regard, so I am
> tempted to rework all the qemu drivers to handle arbitrary layouts.
> They could use a good audit anyway.

I agree here. Still trying to understand whether we can agree to use
a feature bit for this, or not.

> This would become a glaring exception, but I'm tempted to fix it to 32
> bytes at the same time as we get the new pci layout (ie. for the virtio
> 1.0 spec).

But this isn't a virtio-pci only issue, is it?
qemu has s390 bus with same limmitation.
How can we tie it to pci layout?

Maybe what you mean is to use a transport feature for this
and tie *that* to new layout in case of pci?



> The Linux driver would carefully be backwards compatible, of
> course, and the spec would document why.
> 
> Cheers,
> Rusty.
