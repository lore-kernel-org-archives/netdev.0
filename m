From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] rxrpc: Correctly handle ack at end of client call
 transmit phase
Date: Tue, 24 Nov 2015 17:15:15 -0500 (EST)
Message-ID: <20151124.171515.1710534888834295691.davem@redhat.com>
References: <20151124144159.18105.50840.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151124144159.18105.50840.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 24 Nov 2015 14:41:59 +0000

> Normally, the transmit phase of a client call is implicitly ack'd by the
> reception of the first data packet of the response being received.
> However, if a security negotiation happens, the transmit phase, if it is
> entirely contained in a single packet, may get an ack packet in response
> and then may get aborted due to security negotiation failure.
> 
> Because the client has shifted state to RXRPC_CALL_CLIENT_AWAIT_REPLY due
> to having transmitted all the data, the code that handles processing of the
> received ack packet doesn't note the hard ack the data packet.
> 
> The following abort packet in the case of security negotiation failure then
> incurs an assertion failure when it tries to drain the Tx queue because the
> hard ack state is out of sync (hard ack means the packets have been
> processed and can be discarded by the sender; a soft ack means that the
> packets are received but could still be discarded and rerequested by the
> receiver).
> 
> To fix this, we should record the hard ack we received for the ack packet.
> 
> The assertion failure looks like:
...
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
