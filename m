From: Henrik Petander <lpetande@tml.hut.fi>
Subject: Bug in ipv6 ipsec  in handling of packets with extension headers
Date: Thu, 05 Jun 2003 15:25:14 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EDF36AA.9020403@tml.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

There's a bug in get_offset function of ah6 and esp6. The function 
returns also a pointer, prev_hdr, pointing to the last extension header 
before the IPSec headers. This pointer points to the skb. The ipsec 
headers go between the payload and the extension header, making the 
pointer invalid. However, after this the pointer is used for setting the 
next header field of the extension header to IPPROTO_ESP or IPPROTO_AH. 
This corrupts the packet, if any extension headers are present.

An easy way to test this is to send a data packet with routing header 
protected by IPSec.

A possible fix is to change the pointer into an offset from the start of 
the packet and use the offset later to set the nexthdr value in the 
extension header.

Thanks,

Henrik
