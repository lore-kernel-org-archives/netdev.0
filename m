From: Boris Protopopov <borisp@mc.com>
Subject: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Thu, 12 Sep 2002 14:39:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D80DF4F.5B218F19@mc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, I got couple questions about bonding vs link agregation in GigE space. I may
be doing something wrong on the user level, or there might be system-level
issues I am not aware of. 

I am trying to increase bandwidth of GigE connecitons between boxes in my
cluster by means of bonding or aggregating several GigE links together. The
simplest setup that I have is two boxes with dual GigE e1000 cards connected to
each other directly by means of crossover cables. The boxes are running Redhat
7.3. I can successfully bond the links; however, I do not see any increase in
Netpipe bandwidth as compared to the case of a single GigE link. My CPU
utilization is around 20%, and I can get ~900Mbits/sec over a single link (MTU
7500). With bonding, CPU utilization is marginally higher, and there is no
increase (or some decrease) in Netpipe numbers. Looking at the ifconfig eth*
statistics, I can see that the traffic is distributed evenly between the
connections. The cards are plugged into 100Mhz PCI-X 64. Memory bw seems to be
sufficient (estimated with "stream" to be ~ 1200MB/s). Can anybody offer an
explanation ? 

Another question is about link agregation. Intel offers "teaming" option (with
the driver and utils) for agregating the e1000 cards in EtherChannel- or 802.3ad
- compatible way. From a few docs I could find that have any technical merit
(802.3ad doc on order), it appears that there are some sort of Ethernet frame
ordering restrictions that EtherChannel and 802.3ad impose on the traffic spread
across the aggregated links. So, in my case, I can see (ifconfig statistics)
that one link is always sending GigE frames, whereas the other clink is always
receiving. Obviously, in this arrangement, Netpipe will not benefit from the
aggregation. A response that I got from Intel customer support indicated that
"this is how EtherChannel works". Can someone explain why there are some
ordering restrictions ? If I am not mistaken, TCP/IP would handle out-of-order
frames transparently because it is designed to do so.

Thanks in advance for your help,
Boris Protopopov.
