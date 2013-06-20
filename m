From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: qlen check in tun.c
Date: Thu, 20 Jun 2013 11:07:25 +0300
Message-ID: <20130620080725.GB23621@redhat.com>
References: <CAPshTCgdb9FzKHzxkpDpowZjzqBv5yM_rBpcT88YmYBSojN8Tw@mail.gmail.com>
 <51C12592.6050503@redhat.com>
 <CAPshTCj+2wx=LhHujMqiZc1ptvGbcn+V7P9aAhBELHf6cbL+jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755036Ab3FTIGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 04:06:41 -0400
Content-Disposition: inline
In-Reply-To: <CAPshTCj+2wx=LhHujMqiZc1ptvGbcn+V7P9aAhBELHf6cbL+jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 19, 2013 at 12:39:34PM -0700, Jerry Chu wrote:
> Hi Jason,
> 
> On Tue, Jun 18, 2013 at 8:29 PM, Jason Wang <jasowang@redhat.com> wrote:
> > On 06/19/2013 10:31 AM, Jerry Chu wrote:
> >> In tun_net_xmit() the max qlen is computed as
> >> dev->tx_queue_len / tun->numqueues. For multi-queue configuration the
> >> latter may be way too small, forcing one to adjust txqueuelen based
> >> on number of queues created. (Well the default txqueuelen of
> >> 500/TUN_READQ_SIZE already seems too small even for single queue.)
> >
> > Hi Jerry:
> >
> > Do you have some test result of this? Anyway, tun allows userspace to
> > adjust this value based on its requirement.
> 
> Sure, but the default size of 500 is just way too small. queue overflows even
> with a simple single-stream throughput test through Openvswitch due to CPU
> scheduler anomaly. On our loaded multi-stream test even 8192 can't prevent
> queue overflow. But then with 8192 we'll be deep into the "buffer
> bloat" territory.
> We haven't figured out an optimal strategy for thruput vs latency, but
> suffice to
> say 500 is too small.
> 
> Jerry

Maybe TSO is off for you?
With TSO you can get 64Kbyte packets, 500 of these is 30 Mbytes!
We really should consider setting byte limits, not packet limits.
