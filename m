From: Thomas Graf <tgraf@suug.ch>
Subject: Re: filtering packtes before OS takes care about them
Date: Tue, 1 Mar 2005 01:26:26 +0100
Message-ID: <20050301002626.GR31837@postel.suug.ch>
References: <09766A6E64A068419B362367800D50C0B58A18@moritz.faps.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com
To: Weber Matthias <weber@faps.uni-erlangen.de>
Content-Disposition: inline
In-Reply-To: <09766A6E64A068419B362367800D50C0B58A18@moritz.faps.uni-erlangen.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I need to develop a special gateway. It shall map exernal ips to internal ports and external ports to internal ips (kind of NAT but connections have to be established from external to internal network and vice versa!), so the sender,receveiver addresses and ports have to be changed off each package received. Afterwards these packets shall be resent via one (out of more) interfaces. Therefore kernel's IP stuff disturbs me, but because i want to use TCP/IP at the gateway itself too (the computer runs applications using IP), i still need it.

I won't comment on the way you are about to solve your problem even if I
do think that it could be solved in a simpler way. In recent 2.6 kernels
the earliest filtering possibility is via the ingress qdisc right after
the skb has been received, see the ing_filter() call in netif_receive_skb(),
given you enable tc actions. Earlier kernels or if tc actions is not
enabled, the netfilter prerouting hook is used which gets invoked in the
ip code after some very basic sanity checks.

You can use the pedit action to modify the packet although the checksum
correction action is still missing which might bother you.
