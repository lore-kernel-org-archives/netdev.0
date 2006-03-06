From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: RFC: move SDP from AF_INET_SDP to IPPROTO_SDP
Date: Mon, 6 Mar 2006 12:16:51 -0800
Message-ID: <54AD0F12E08D1541B826BE97C98F99F12FBF33@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751363AbWCFURV@vger.kernel.org>
Content-class: urn:content-classes:message
To: "David Stevens" <dlstevens@us.ibm.com>,
	"Michael S. Tsirkin" <mst@mellanox.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of David Stevens
> Sent: Monday, March 06, 2006 11:49 AM
> To: Michael S. Tsirkin
> Cc: Linux Kernel Mailing List; netdev@vger.kernel.org
> Subject: Re: RFC: move SDP from AF_INET_SDP to IPPROTO_SDP
> 
> I don't know any details about SDP, but if there are no 
> differences at the protocol layer, then neither the address 
> family nor the protocol is appropriate. If it's just an API 
> change, the socket type is the right selector. So, maybe 
> SOCK_DIRECT to go along with SOCK_STREAM, SOCK_DGRAM, etc.
>                                         +-DLS

That wouldn't work either. The whole point of SDP, or TOE,
is that the API is either totally unchanged or at least
essentially unchanged.

Whenever an IP Address is used (SDP/iWARP, TOE and potentially
SDP/IB) changing from AF_INET* is wrong.

For both SDP/iWARP and SDP/IB you could argue that a different
wire protocol is in use so IPPROTO_SDP is acceptable.
That's probably the best answer as long as we are stuck
under the restriction that the selection of an alternate
stack cannot be done in the exact manner that the consumer
wants it done (that is transparently to the application).

There are even some corner case scenarios where the 
application might care whether their SOCK_STREAM was
carried over SDP or plain TCP. So a protocol based
distinction is probably the least misleading of all
the explicit selection options.
