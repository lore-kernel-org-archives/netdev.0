From: "David S. Miller" <davem@redhat.com>
Subject: Re: TCP IP Offloading Interface
Date: Sun, 13 Jul 2003 00:48:18 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030713004818.4f1895be.davem@redhat.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "Alan Shih" <alan@storlinksemi.com>
In-Reply-To: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>
List-Id: netdev.vger.kernel.org

On Sun, 13 Jul 2003 00:33:00 -0700
"Alan Shih" <alan@storlinksemi.com> wrote:

> Or TOE is a forbidden discussion?

TOE is evil, read this:

http://www.usenix.org/events/hotos03/tech/full_papers/mogul/mogul.pdf

TOE is exactly suboptimal for the very things performance
matters, high connection rates.

Your return is also absolutely questionable.  Servers "serve" data
and we offload all of the send side TCP processing that can
reasonably be done (segmentation, checksumming).

I've never seen an impartial benchmark showing that TCP send
side performance goes up as a result of using TOE vs. the usual
segmentation + checksum offloading offered today.

On receive side, clever RX buffer flipping tricks are the way
to go and require no protocol changes and nothing gross like
TOE or weird buffer ownership protocols like RDMA requires.

I've made postings showing how such a scheme can work using a limited
flow cache on the networking card.  I don't have a reference handy,
but I suppose someone else does.

And finally, this discussion belongs on the "networking" lists.
Nearly all of the "networking" developers don't have time to sift
through linux-kernel every day.
