From: Patrick McManus <mcmanus@ducksong.com>
Subject: RFC [PATCH 0/3] TCP_DEFER_ACCEPT updates
Date: Tue, 26 Feb 2008 20:48:56 -0500
Message-ID: <1204076936.15970.33.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a few patches to try and improve the TCP_DEFER_ACCEPT
implementation. The first two are simple, the third is ante for a
discussion on how this should really be implemented.

Patch 1 : timeout values could not be less than allowed by the max
syn-recv queue size algorithms. This was not simply a matter of rounding
up to the next syn-ack retransmit time, it was enforcing at least 5
retransmits on a non-loaded machine even if the timeout (expressed by
the API in seconds) was set to 1.

Patch 2 : a socket that has completed its handshake but which is waiting
for the first data packet was retransmitting its syn-ack during that
period. This patch suppresses that transmission.

Patch 3 : move the connected (and TCP_DEFER'd) socket to ESTABLISHED
after the handshake, but defer placing it in the accept queue until some
data arrives. 

RFC?

-Patrick


