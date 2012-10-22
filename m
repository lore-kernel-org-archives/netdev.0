From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Prioritizing IPs on interface with multiple addresses
Date: Mon, 22 Oct 2012 11:36:37 +0200
Message-ID: <CAKfDRXiAL37+H2k0SepwmUzYv4chtKr_Fn0CQSFt2UV5NejsUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, netfilter@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am currently working on configuring an embedded system that will be
used as an access point for other devices. In order to reduce the
number of external devices, we want to connect the LAN on the embedded
system to a switch. Then, two separate networks will also be connected
to this switch, and the LAN interface assigned one IP from each
network. The IPs are static and network addresses are not overlapping.
One interface is the main interface for all traffic from clients,
while the other is used as fallback and for some monitoring traffic.
The clients that connect to this AP will be assigned IPs using DHCP
and traffic from them will be NAT'ed.

Initially, this setup works fine. The devices connected to this AP are
able to send traffic through the intended network and to the correct
hosts. If I disconnect from the main network, the routing tables are
updated and traffic is routed through the secondary network. However,
when I connect to the main network again, things break. The problem is
that there is an inconsistency between the order in the routing table
and the order of IP addresses assigned to the interface, which causes
problems when I do NAT (MASQUERADE). The default route (with the
lowest metric) points to the main network, but the first IP address
belongs to the secondary network. So what happens is that the packets
have the MAC-address of the first hop in the main network, but a
source IP address from the second network (chosen by the NAT). This
causes the traffic to be discarded by the network. Deleting (and then
later adding) the IP of the secondary network is not an option as it
is needed for the monitoring traffic.

My question is, is there some way to prioritize the different IP
addresses assigned to an interface? For example, is there an
equivalent to a metric, index or something similar? Based on my
understanding, ip addr is only able to append addresses. I believe
this would solve the problem, as it would then be possible to ensure
that addresses and the routing table are in sync.

Another soulution would be to monitor network events and create/delete
SNAT rules on-demand, but this is a big hack if you ask me and I would
like to try to avoid it.

Thanks in advance for any help!
Kristian
