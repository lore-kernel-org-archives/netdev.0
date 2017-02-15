From: Benjamin Serebrin <serebrin@google.com>
Subject: Re: [PATCH v2 net-next] virtio: Fix affinity for #VCPUs != #queue pairs
Date: Wed, 15 Feb 2017 10:27:37 -0800
Message-ID: <CAN+hb0V5hcMkWwQhk=5G4B+vWBARyEq+g-=XVaygH5s-s7mPZw@mail.gmail.com>
References: <20170207181506.36668-1-serebrin@google.com> <20170208205353-mutt-send-email-mst@kernel.org>
 <CAN+hb0Uen4_bHR8xPcUNZG+aKPYAvjUqY1Z4PA7WWOs7jG3EAA@mail.gmail.com>
 <20170214225629-mutt-send-email-mst@kernel.org> <CAF=yD-La6wL16Ej0jGw1ztiKOGpWoaY86E3Qe4KmskrjczrC_A@mail.gmail.com>
 <20170215185413-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20170215185413-mutt-send-email-mst@kernel.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2017 at 9:42 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>
>
> > For pure network load, assigning each txqueue IRQ exclusively
> > to one of the cores that generates traffic on that queue is the
> > optimal layout in terms of load spreading. Irqbalance does
> > not have the XPS information to make this optimal decision.
>
> Try to add hints for it?
>
>
> > Overall system load affects this calculation both in the case of 1:1
> > mapping uneven queue distribution. In both cases, irqbalance
> > is hopefully smart enough to migrate other non-pinned IRQs to
> > cpus with lower overall load.
>
> Not if everyone starts inserting hacks like this one in code.


It seems to me that the default behavior is equally "random" - why would we want
XPS striped across the cores the way it's done today?

What we're trying to do here is avoid the surprise cliff that guests will
hit when queue count is limited to less than VCPU count.  That will
happen because
we limit queue pair count to 32.  I'll happily push further complexity
to user mode.

If this won't fly, we can leave all of this behavior in user code.
Michael, would
you prefer that I abandon this patch?

> That's another problem with this patch. If you care about hyperthreads
> you want an API to probe for that.


It's something of a happy accident that hyperthreads line up that way.
Keeping the topology knowledge out of the patch and into user space seems
cleaner, would you agree?

Thanks!
Ben
