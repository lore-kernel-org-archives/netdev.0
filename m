From: Mark Smith <markzzzsmith@ozemail.com.au>
Subject: [2.4.20] Frustrating DNS / UDP Socket flakeyness
Date: 21 Apr 2003 02:05:32 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1050856532.1816.22.camel@dupy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm having trouble with UDP based DNS queries when my 33.6 Kbps ppp link
is under load eg while performing a TCP file transfer / HTTP etc.

While a TCP download is running, the UDP / DNS queries are sent, a
response comes back from the DNS server, but for some reason, in the
kernel appears to have closed the UDP socket, and therefore generates an
ICMP destination unreachable, port unreachable message back to the DNS
server.

The problem happens irrespective of whether I trigger the DNS lookup via
phoenix, wget or the djb utility dnsip.

There are no problems with these UDP / DNS queries if the link is not
busy.

I've stored some packet traces here :

Full packet dump, including HTTP transfer :

http://members.ozemail.com.au/~markzzzsmith/flakey-udpsocket.libpcap.gz

Just the UDP DNS query, response, and corresponding ICMP dest
unreachable.

http://members.ozemail.com.au/~markzzzsmith/flakey-udpsocket-nontcp.libpcap.gz


My system is running up-to-date debian 3.0, with a pure 2.4.20 kernel,
with the following networking options :

--
#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
# CONFIG_NETLINK_DEV is not set
# CONFIG_NETFILTER is not set
# CONFIG_FILTER is not set
CONFIG_UNIX=y
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_ARPD is not set
CONFIG_INET_ECN=y
# CONFIG_SYN_COOKIES is not set
# CONFIG_IPV6 is not set
# CONFIG_KHTTPD is not set
# CONFIG_ATM is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
--

Just in case it is useful, the full kernel config is here :

http://www.nosense.org/2.4.20-dupy.netslim


I normally compile about all the networking options into the kernel, the
same problem was occurring. It also seemed to be present in 2.4.19.

Please let me know if I can be of further assistance in diagnosing this
problem. 

Thanks,
Mark.
