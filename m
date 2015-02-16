From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/5] virtio: Don't expose legacy net features when VIRTIO_NET_NO_LEGACY defined.
Date: Mon, 16 Feb 2015 13:59:17 +1030
Message-ID: <87y4ny8rg2.fsf@rustcorp.com.au>
References: <1423199216-2094-1-git-send-email-rusty@rustcorp.com.au> <1423199216-2094-4-git-send-email-rusty@rustcorp.com.au> <20150208105908.GI3185@redhat.com> <20150214204326.GA31803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: lkml <linux-kernel@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150214204326.GA31803@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On Sun, Feb 08, 2015 at 11:59:08AM +0100, Michael S. Tsirkin wrote:
>> On Fri, Feb 06, 2015 at 03:36:54PM +1030, Rusty Russell wrote:
>> > In particular, the virtio header always has the u16 num_buffers field.
>> > We define a new 'struct virtio_net_modern_hdr' for this (rather than
>> > simply calling it 'struct virtio_net_hdr', to avoid nasty type errors
>> > if some parts of a project define VIRTIO_NET_NO_LEGACY and some don't.
>> 
>> This kind of masks the fact that it's the same as
>> virtio_net_hdr_mrg_rxbuf. So it's forcing people to duplicate
>> code for transitional devices.
>> 
>> How about
>> struct virtio_net_modern_hdr {
>> 	struct virtio_net_hdr_mrg_rxbuf hdr;
>> }
>> 
>> 
>> This will also make it look nicer when we start
>> adding stuff in the header, the main header
>> is separated in a struct by its own, so it's
>> easy to apply operations such as sizeof.
>
> Ping.
> Would you like a patch on top that does this?

Hmm, I thought I replied...

Indeed, I did.  I disagreed, and simply renamed struct
virtio_net_modern_hdr to virtio_net_hdr_v1.

Cheers,
Rusty.
