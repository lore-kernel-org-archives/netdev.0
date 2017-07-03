From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: unbreak cusmed packet for small buffer
 XDP
Date: Mon, 3 Jul 2017 20:03:57 +0300
Message-ID: <20170703195752-mutt-send-email-mst@kernel.org>
References: <1498614843-8163-1-git-send-email-jasowang@redhat.com>
 <20170628050057-mutt-send-email-mst@kernel.org>
 <7068053c-50da-6779-5ff2-6588e01e616d@redhat.com>
 <20170628051555-mutt-send-email-mst@kernel.org>
 <69907228-fc1b-175f-f6cd-7ac332e318be@redhat.com>
 <20170628063033-mutt-send-email-mst@kernel.org>
 <51f4c402-6a02-9bad-6dab-563ca72f431a@redhat.com>
 <20170628065126-mutt-send-email-mst@kernel.org>
 <a7e457d5-88c4-745d-5189-18a5f13797dc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a7e457d5-88c4-745d-5189-18a5f13797dc@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 28, 2017 at 08:05:06PM +0800, Jason Wang wrote:
> 
> 
> On 2017年06月28日 12:01, Michael S. Tsirkin wrote:
> > On Wed, Jun 28, 2017 at 11:40:30AM +0800, Jason Wang wrote:
> > > 
> > > On 2017年06月28日 11:31, Michael S. Tsirkin wrote:
> > > > On Wed, Jun 28, 2017 at 10:45:18AM +0800, Jason Wang wrote:
> > > > > On 2017年06月28日 10:17, Michael S. Tsirkin wrote:
> > > > > > On Wed, Jun 28, 2017 at 10:14:34AM +0800, Jason Wang wrote:
> > > > > > > On 2017年06月28日 10:02, Michael S. Tsirkin wrote:
> > > > > > > > On Wed, Jun 28, 2017 at 09:54:03AM +0800, Jason Wang wrote:
> > > > > > > > > We should allow csumed packet for small buffer, otherwise XDP_PASS
> > > > > > > > > won't work correctly.
> > > > > > > > > 
> > > > > > > > > Fixes commit bb91accf2733 ("virtio-net: XDP support for small buffers")
> > > > > > > > > Signed-off-by: Jason Wang<jasowang@redhat.com>
> > > > > > > > The issue would be VIRTIO_NET_HDR_F_DATA_VALID might be set.
> > > > > > > > What do you think?
> > > > > > > I think it's safe. For XDP_PASS, it work like in the past.
> > > > > > That's the part I don't get. With DATA_VALID csum in packet is wrong, XDP
> > > > > > tools assume it's value.
> > > > > DATA_VALID is CHECKSUM_UNCESSARY on the host, and according to the comment
> > > > > in skbuff.h
> > > > > 
> > > > > 
> > > > > "
> > > > >    *   The hardware you're dealing with doesn't calculate the full checksum
> > > > >    *   (as in CHECKSUM_COMPLETE), but it does parse headers and verify
> > > > > checksums
> > > > >    *   for specific protocols. For such packets it will set
> > > > > CHECKSUM_UNNECESSARY
> > > > >    *   if their checksums are okay. skb->csum is still undefined in this case
> > > > >    *   though. A driver or device must never modify the checksum field in the
> > > > >    *   packet even if checksum is verified.
> > > > > "
> > > > > 
> > > > > The csum is correct I believe?
> > > > > 
> > > > > Thanks
> > > > That's on input. But I think for tun it's output, where that is equivalent
> > > > to CHECKSUM_NONE
> > > > 
> > > > 
> > > Yes, but the comment said:
> > > 
> > > "
> > > CKSUM_NONE:
> > >   *
> > >   *   The skb was already checksummed by the protocol, or a checksum is not
> > >   *   required.
> > >   *
> > >   * CHECKSUM_UNNECESSARY:
> > >   *
> > >   *   This has the same meaning on as CHECKSUM_NONE for checksum offload on
> > >   *   output.
> > >   *
> > > "
> > > 
> > > So still correct I think?
> > > 
> > > Thanks
> > Hmm maybe I mean NEEDS_CHECKSUM actually.
> > 
> > I'll need to re-read the spec.
> > 
> 
> Not sure this is an issue. But if it is, we can probably checksum the packet
> before passing it to XDP. But it would be a little slow.
> 
> Thanks



Right. I confused DATA_VALID with NEEDS_CHECKSUM.

IIUC XDP generally refuses to attach if checksum offload
is enabled.

Could you pls explain how to reproduce the issue you are seeing?

-- 
MST
