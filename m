From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC 2/2] vhost_net: basic polling support
Date: Thu, 22 Oct 2015 19:16:02 +0300
Message-ID: <20151022191456-mutt-send-email-mst@redhat.com>
References: <1445491649-62614-1-git-send-email-jasowang@redhat.com>
 <1445491649-62614-2-git-send-email-jasowang@redhat.com>
 <20151022113824-mutt-send-email-mst@redhat.com>
 <562904D9.9080109@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <562904D9.9080109@hpe.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 08:46:33AM -0700, Rick Jones wrote:
> On 10/22/2015 02:33 AM, Michael S. Tsirkin wrote:
> >On Thu, Oct 22, 2015 at 01:27:29AM -0400, Jason Wang wrote:
> >>This patch tries to poll for new added tx buffer for a while at the
> >>end of tx processing. The maximum time spent on polling were limited
> >>through a module parameter. To avoid block rx, the loop will end it
> >>there's new other works queued on vhost so in fact socket receive
> >>queue is also be polled.
> >>
> >>busyloop_timeout = 50 gives us following improvement on TCP_RR test:
> >>
> >>size/session/+thu%/+normalize%
> >>     1/     1/   +5%/  -20%
> >>     1/    50/  +17%/   +3%
> >
> >Is there a measureable increase in cpu utilization
> >with busyloop_timeout = 0?
> 
> And since a netperf TCP_RR test is involved, be careful about what netperf
> reports for CPU util if that increase isn't in the context of the guest OS.
> 
> For completeness, looking at the effect on TCP_STREAM and TCP_MAERTS,
> aggregate _RR and even aggregate _RR/packets per second for many VMs on the
> same system would be in order.
> 
> happy benchmarking,
> 
> rick jones

Absolutely, merging a new kernel API just for a specific
benchmark doesn't make sense.
I'm guessing this is just an early RFC, a fuller submission
will probably include more numbers.

-- 
MST
