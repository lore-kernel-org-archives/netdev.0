From: James Morris <jmorris@intercode.com.au>
Subject: Re: IPSEC problems with GRE.
Date: Tue, 17 Jun 2003 21:28:45 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306172117310.14332-100000@excalibur.intercode.com.au>
References: <1055746871.2305.7.camel@festa.omgwallhack.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>,
   "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Blake Kongslie <jblake@omgwallhack.org>
In-Reply-To: <1055746871.2305.7.camel@festa.omgwallhack.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 16 Jun 2003, Julian Blake Kongslie wrote:

> Hi there.
> 
> I've been playing around with IPSec, and I came across a problem with
> encrypting data sent directly by the kernel.
> 
> Specifically, attempts to encrypt a GRE or IPIP tunnel with ipsec in
> transport mode result in one of:
> 	1) No data sent.
> 	2) Data sent, ignored by peer.
> 	3) Kernel panic, with no SysRq.
> 
> Numbers 1 and 2 might be configuration problems on my part, but I have
> other ipsec setups running fine, and can't see anything different for
> these. Number 3 is a big problem.

I've not been able to reproduce the panic, but there is a potential issue
with path mtu which could explain (1) and (2):  the transport mode SAs 
between the gateways are not aware of the gre tunnel.

You need to lower the mtu on the gre tunnel at each end to take the ipsec
overhead into account.  This will cause the gateways to generate
appropriate icmp pmtu messages.

This is handled automatically for tunnel mode ipsec configurations.


- James
-- 
James Morris
<jmorris@intercode.com.au>
