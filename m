From: Hasso Tepper <hasso@estpak.ee>
Subject: IPv6 and netlink
Date: Tue, 23 Nov 2004 23:22:50 +0200
Message-ID: <200411232322.50083.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While debugging IPv6 RIB in Quagga routing software I discovered some issues 
with kernel rtnetlink messages.

1) RTM_NEWROUTE message with prefix ff00::/8 (if interface goes up or down) 
is sent with rtm_type set to RTN_UNICAST. It's multicast route, so why not 
RTN_MULTICAST? Is it bug?

2) If address is added to the interface, route is created by kernel to route 
prefix to the intarface. In IPv4 these routes have rtm_protocol set to 
RTPROT_KERNEL if announced it via rtnetlink, but that's not the case with 
IPv6. It doesn't matter if address is added by the user or it's the link 
local address (fe80::/64 route). Is it intentional or bug?

3) Not really rtnetlink related, but if this address is removed from 
interface, route created by kernel (when address was added) isn't removed 
from table. Is it intentional?


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
