From: Roland Dreier <roland@topspin.com>
Subject: Re: TCP IP Offloading Interface
Date: 13 Jul 2003 09:22:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <52u19qwg53.fsf@topspin.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>
	<20030713004818.4f1895be.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Alan Shih" <alan@storlinksemi.com>, linux-kernel@vger.kernel.org,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030713004818.4f1895be.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    David> TOE is evil, read this:

    David> http://www.usenix.org/events/hotos03/tech/full_papers/mogul/mogul.pdf

    David> TOE is exactly suboptimal for the very things performance
    David> matters, high connection rates.

    David> Your return is also absolutely questionable.  Servers
    David> "serve" data and we offload all of the send side TCP
    David> processing that can reasonably be done (segmentation,
    David> checksumming).

    David> I've never seen an impartial benchmark showing that TCP
    David> send side performance goes up as a result of using TOE
    David> vs. the usual segmentation + checksum offloading offered
    David> today.

    David> On receive side, clever RX buffer flipping tricks are the
    David> way to go and require no protocol changes and nothing gross
    David> like TOE or weird buffer ownership protocols like RDMA
    David> requires.

    David> I've made postings showing how such a scheme can work using
    David> a limited flow cache on the networking card.  I don't have
    David> a reference handy, but I suppose someone else does.

Your ideas are certainly very interesting, and I would be happy to see
hardware that supports flow identification.  But the Usenix paper
you're citing completely disagrees with you!  For example, Mogul writes:

 "Nevertheless, copy-avoidance designs have not been widely adopted,
  due to significant limitations. For example, when network maximum
  segment size (MSS) values are smaller than VM page sizes, which is
  often the case, page-remapping techniques are insufficient (and
  page-remapping often imposes overheads of its own.)"

In fact, his conclusion is:

 "However, as hardware trends change the feasibility and economics of
  network-based storage connections, RDMA will become a significant
  and appropriate justification for TOEs."

 - Roland
