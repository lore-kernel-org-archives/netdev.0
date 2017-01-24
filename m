From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] virtio_net: fix PAGE_SIZE > 64k
Date: Tue, 24 Jan 2017 22:45:37 +0200
Message-ID: <20170124221114-mutt-send-email-mst@kernel.org>
References: <1485197869-11350-1-git-send-email-mst@redhat.com>
 <20170124.144227.2017106704873029028.davem@davemloft.net>
 <20170124215214-mutt-send-email-mst@kernel.org>
 <20170124.150959.1708982899683381291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170124.150959.1708982899683381291.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2017 at 03:09:59PM -0500, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Tue, 24 Jan 2017 21:53:13 +0200
> 
> > I didn't realise. Why can't we? I thought that adjust_header is an
> > optional feature that userspace can test for, so no rush.
> 
> No, we want the base set of XDP features to be present in all drivers
> supporting XDP.

I see, I didn't realize this. In light of this, is there any
guidance *how much* head room is required to be considered
valid? We already have 12 bytes of headroom.


I'm generally sorry it's taking long, a large part of that is difficulty
figuring out the requirements: when we discussed this on LPC my
take-away was that one of the first users will be fighting DDOS attacks.

In light of this, I assumed that
- supporting just DROP (or DROP+TX) would already be useful
- XDP_PASS shouldn't be too slow as some people will run all
  their traffic with XDP enabled
- people actually want this in virtio because they run in a vm

Since then I heard opinions that seem to imply that
- you must support all features, not just DROP, otherwise it's useless
- XDP_PASS is a slow path fallback as people are not expected to mix XDP
  with regular sockets
- DDOS protection and by extension XDP in virtio is a developer's toy anyway

Thus, expect some slowness while I figure it all out.

-- 
MST
