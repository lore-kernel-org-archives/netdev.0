From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net-next] virtio: Fix affinity for #VCPUs != #queue
 pairs
Date: Wed, 15 Feb 2017 23:49:32 +0200
Message-ID: <20170215234333-mutt-send-email-mst@kernel.org>
References: <20170207181506.36668-1-serebrin@google.com>
 <20170208205353-mutt-send-email-mst@kernel.org>
 <CAN+hb0Uen4_bHR8xPcUNZG+aKPYAvjUqY1Z4PA7WWOs7jG3EAA@mail.gmail.com>
 <20170214225629-mutt-send-email-mst@kernel.org>
 <CAF=yD-La6wL16Ej0jGw1ztiKOGpWoaY86E3Qe4KmskrjczrC_A@mail.gmail.com>
 <20170215185413-mutt-send-email-mst@kernel.org>
 <CAN+hb0V5hcMkWwQhk=5G4B+vWBARyEq+g-=XVaygH5s-s7mPZw@mail.gmail.com>
 <20170215210941-mutt-send-email-mst@kernel.org>
 <CAN+hb0X4UWmDvA0=5gpC6+Qt7vDgz0u5B79CM4KqQ-yuJmAO7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        "Jon Olson (Google Drive)" <jonolson@google.com>,
        Rick Jones <rick.jones2@hpe.com>,
        James Mattson <jmattson@google.com>,
        linux-s390 <linux-s390@vger.kernel.org>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>
To: Benjamin Serebrin <serebrin@google.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAN+hb0X4UWmDvA0=5gpC6+Qt7vDgz0u5B79CM4KqQ-yuJmAO7Q@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2017 at 01:38:48PM -0800, Benjamin Serebrin wrote:
> On Wed, Feb 15, 2017 at 11:17 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> 
> > Right. But userspace knows it's random at least. If kernel supplies
> > affinity e.g. the way your patch does, userspace ATM accepts this as a
> > gospel.
> 
> The existing code supplies the same affinity gospels in the #vcpu ==
> #queue case today.
> And the patch (unless it has a bug in it) should not affect the #vcpu
> == #queue case's
> behavior.  I don't quite understand what property we'd be changing
> with the patch.
> 
> Here's the same dump of smp_affinity_list, on a 16 VCPU machine with
> unmodified kernel:
> 
> 0
> 0
> 1
> 1
> 2
> 2
> [..]
> 15
> 15
> 
> And xps_cpus
> 00000001
> 00000002
> [...]
> 00008000
> 
> This patch causes #vcpu != #queue case to follow the same pattern.
> 
> 
> Thanks again!
> Ben

The logic is simple really. With #VCPUs == #queues we can reasonably
assume this box is mostly doing networking so we can set affinity
the way we like. With VCPUs > queues clearly VM is doing more stuff
so we need a userspace policy to take that into account,
we don't know ourselves what is the right thing to do.

Arguably for #VCPUs == #queues we are not always doing the right thing
either but I see this as an argument to move more smarts
into core kernel not for adding more dumb heuristics in the driver.

-- 
MST
