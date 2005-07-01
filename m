From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: problems with 2.6.12
Date: Fri, 01 Jul 2005 18:33:28 +0200
Message-ID: <42C57058.70806__32954.5891298496$1120235321$gmane$org@tpack.net>
References: <42C562A4.9070501@lammerts.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: madwifi-devel@lists.sourceforge.net, herbert@gondor.apana.org.au,
        davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lammerts <eric-madwifi-devel@lammerts.org>
In-Reply-To: <42C562A4.9070501@lammerts.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Lammerts wrote:
> Hello all,
> I was having problems with 2.6.12 + madwifi in master mode. No packets 
> were going out. With tcpdump I see DHCP requests coming in, with strace 
> I see the dhcp daemon sending replies out, but they don't show up in 
> tcpdump.
> 
> It's caused by this change:
> http://oss.sgi.com/projects/netdev/archive/2005-05/msg00109.html
> 
> which btw also causes problems for other people:
> http://marc.theaimsgroup.com/?l=linux-kernel&m=111853727810345&w=2

Auch. And vlan interfaces are having trouble as well.

> Madwifi doesn't call netif_carrier_on() in master mode, so Linux drops 
> all packets. When I remove the dev_deactivate() line, it works fine again.

Netdevices are "born" with carrier on, so if your code don't call
netif_carrier_off() or set dev->state directly, I don't see how you
can end up in this state. Could you investigate this?

> Should we fix madwifi or the kernel?

The code is there for a reason, so hopefully we can work this out.


-Tommy
