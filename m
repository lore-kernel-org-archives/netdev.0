From: Jeroen Vreeken <pe1rxq@amsat.org>
Subject: Re: [PATCH] ax25 & netrom fixes for 2.6
Date: Tue, 12 Aug 2003 23:09:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812230951.E28977@jeroen.pe1rxq.ampr.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org> <20030812135655.7334887b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Jeroen Vreeken <pe1rxq@amsat.org>, linux-hams@vger.kernel.org,
   ralf@linux-mips.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030812135655.7334887b.shemminger@osdl.org>; from shemminger@osdl.org on Tue, Aug 12, 2003 at 22:56:55 +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 2003.08.12 22:56:55 +0200 Stephen Hemminger wrote:
> It looks like af_x25 is advertising itself as a new style protocol, yet
> if
> I walk the receive path:
> 	ax25_kiss_rcv -> ax25_rcv -> ax25_addr_parse
> there is no place that checks that the address portion of the buffer
> isn't fragmented
> into a non_linear skb.

Since at the moment the only zero-copy path I can imagine is from packets
over a bpq ethernet device wouldn't it be the easiest to just check at
ax25_rcv() for non-linear packets and call skb_linearize() for them? That
way we would be safe untill we can make sure that the whole of the ax25
stack is non-linear safe?
Should I make a new patch with this included? (and possibly the ifconfig
problem you mentioned?)

Jeroen
