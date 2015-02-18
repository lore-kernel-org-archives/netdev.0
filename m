From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: support upto 509 memory regions
Date: Wed, 18 Feb 2015 05:27:39 +0100
Message-ID: <20150218042739.GA22891@redhat.com>
References: <1423842599-5174-1-git-send-email-imammedo@redhat.com>
 <20150217090242.GA20254@redhat.com>
 <54E31F24.1060705@redhat.com>
 <20150217123212.GA6362@redhat.com>
 <CAG7+5M1N53tXU72W1i937xZHxc7+sF=JhA6+QWmcarNnApbgiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paolo Bonzini <pbonzini@redhat.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	KVM <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Eric Northup <digitaleric@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576AbbBRE1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2015 23:27:44 -0500
Content-Disposition: inline
In-Reply-To: <CAG7+5M1N53tXU72W1i937xZHxc7+sF=JhA6+QWmcarNnApbgiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 17, 2015 at 04:53:45PM -0800, Eric Northup wrote:
> On Tue, Feb 17, 2015 at 4:32 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Tue, Feb 17, 2015 at 11:59:48AM +0100, Paolo Bonzini wrote:
> >>
> >>
> >> On 17/02/2015 10:02, Michael S. Tsirkin wrote:
> >> > > Increasing VHOST_MEMORY_MAX_NREGIONS from 65 to 509
> >> > > to match KVM_USER_MEM_SLOTS fixes issue for vhost-net.
> >> > >
> >> > > Signed-off-by: Igor Mammedov <imammedo@redhat.com>
> >> >
> >> > This scares me a bit: each region is 32byte, we are talking
> >> > a 16K allocation that userspace can trigger.
> >>
> >> What's bad with a 16K allocation?
> >
> > It fails when memory is fragmented.
> >
> >> > How does kvm handle this issue?
> >>
> >> It doesn't.
> >>
> >> Paolo
> >
> > I'm guessing kvm doesn't do memory scans on data path,
> > vhost does.
> >
> > qemu is just doing things that kernel didn't expect it to need.
> >
> > Instead, I suggest reducing number of GPA<->HVA mappings:
> >
> > you have GPA 1,5,7
> > map them at HVA 11,15,17
> > then you can have 1 slot: 1->11
> >
> > To avoid libc reusing the memory holes, reserve them with MAP_NORESERVE
> > or something like this.
> 
> This works beautifully when host virtual address bits are more
> plentiful than guest physical address bits.  Not all architectures
> have that property, though.

AFAIK this is pretty much a requirement for both kvm and vhost,
as we require each guest page to also be mapped in qemu memory.

> > We can discuss smarter lookup algorithms but I'd rather
> > userspace didn't do things that we then have to
> > work around in kernel.
> >
> >
> > --
> > MST
> > --
> > To unsubscribe from this list: send the line "unsubscribe kvm" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
