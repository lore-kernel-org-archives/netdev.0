From: "David S. Miller" <davem@redhat.com>
Subject: Re: skb->len
Date: Mon, 23 Sep 2002 17:43:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020923.174326.82525292.davem@redhat.com>
References: <Pine.LNX.4.33L2.0204091358030.22258-100000@dragon.pdx.osdl.net>
	<20020410.202811.103858854.davem@redhat.com>
	<20020923182554.1f84d429.mazhar@nmt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mazhar@nmt.edu
In-Reply-To: <20020923182554.1f84d429.mazhar@nmt.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Mazhar Memon <mazhar@nmt.edu>
   Date: Mon, 23 Sep 2002 18:25:54 -0600

   Is there a reason why skb->len for skb->pkt_type=PACKET_OUTGOING is
   14 bytes larger than for skb->pkt_type=PACKET_HOST?  I doubt its a
   coincidence that the size of the ethernet header is 14 bytes.
   Also, I notice that skb->data starts at a different location
   (relative to the ethernet header) if its outgoing compared to
   incoming traffic.  Can anyone tell me why?

The size of skb->len has no direct relationship to skb->pkt_type.

It has more to do with the path the SKB took inside the stack
on it's way to the output device.

On input, the hardware layer trims the device hw header from the front
of the packet by the time ip_input sees it, for example.  The hw header
is still there and accessible actually, via skb->mac.raw
