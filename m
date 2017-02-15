From: Benjamin Serebrin <serebrin@google.com>
Subject: Re: [PATCH v2 net-next] virtio: Fix affinity for #VCPUs != #queue pairs
Date: Wed, 15 Feb 2017 13:38:48 -0800
Message-ID: <CAN+hb0X4UWmDvA0=5gpC6+Qt7vDgz0u5B79CM4KqQ-yuJmAO7Q@mail.gmail.com>
References: <20170207181506.36668-1-serebrin@google.com> <20170208205353-mutt-send-email-mst@kernel.org>
 <CAN+hb0Uen4_bHR8xPcUNZG+aKPYAvjUqY1Z4PA7WWOs7jG3EAA@mail.gmail.com>
 <20170214225629-mutt-send-email-mst@kernel.org> <CAF=yD-La6wL16Ej0jGw1ztiKOGpWoaY86E3Qe4KmskrjczrC_A@mail.gmail.com>
 <20170215185413-mutt-send-email-mst@kernel.org> <CAN+hb0V5hcMkWwQhk=5G4B+vWBARyEq+g-=XVaygH5s-s7mPZw@mail.gmail.com>
 <20170215210941-mutt-send-email-mst@kernel.org>
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
In-Reply-To: <20170215210941-mutt-send-email-mst@kernel.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2017 at 11:17 AM, Michael S. Tsirkin <mst@redhat.com> wrote:

> Right. But userspace knows it's random at least. If kernel supplies
> affinity e.g. the way your patch does, userspace ATM accepts this as a
> gospel.

The existing code supplies the same affinity gospels in the #vcpu ==
#queue case today.
And the patch (unless it has a bug in it) should not affect the #vcpu
== #queue case's
behavior.  I don't quite understand what property we'd be changing
with the patch.

Here's the same dump of smp_affinity_list, on a 16 VCPU machine with
unmodified kernel:

0
0
1
1
2
2
[..]
15
15

And xps_cpus
00000001
00000002
[...]
00008000

This patch causes #vcpu != #queue case to follow the same pattern.


Thanks again!
Ben
