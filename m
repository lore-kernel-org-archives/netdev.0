From: Devesh Agrawal <devesh.agrawal@gmail.com>
Subject: How to route a skb to a particular oif, when the fib_lookup suggests another one.
Date: Sat, 26 Mar 2005 11:20:22 +0530
Message-ID: <db01ab3505032521504ac85fcc@mail.gmail.com>
References: <db01ab3505032313427fcd144f@mail.gmail.com>
	 <db01ab3505032313517830af81@mail.gmail.com>
Reply-To: Devesh Agrawal <devesh.agrawal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <db01ab3505032313517830af81@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I have to route a packet thru a particular output interface, however
my routing tables have two routes, that match it : one to eth0 and one
to wlan0, with the eth0 being chosen as it is more specific.  I am
using ip_route_output_key, with fl->oif = index of device I want this
packet to go (=wlan0).
However, in the ip_route_output_slow I found that even when oif is not
0, you get a valid dev_out, however when the fib_lookup succeeds, you
merely free this old dev_out, and assign dev_out to the res.dev (ie
the one found out by the fib_lookup),
So this means that even if I specify the oif, the packet will still
get routed to eth0.
Am I correct, or is there something I am missing. Also I am setting
tos bit RTO_ONLINK .
Please help me. I am quite perplexed by this.
Sincerely,
--
Devesh Agrawal
