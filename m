From: Bill Leckey <bleckey@tpg.com.au>
Subject: Net device queries.
Date: Mon, 11 Nov 2002 02:30:09 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DCE7B81.4070604@tpg.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been coding an ethernet driver for some new hardware we're
developing and while it's working, there are a few issues I'm still
unsure of.  I couldn't find any archives for this list, so I'm
suspecting I'm going to cover a lot of 'old ground'.  Most of my info 
for coding ethernet drivers comes out of Rubini and Corbet's LInux 
Device Drivers, and what I've gleaned from kernel sources

Firstly some background.  With these cards I can have up to 25 point to
point connections (to the same destination machine, or 25 destination
machines).  I have almost total control of what goes out on the wire, so
I've chosen a minimal header that contains the type (passed in to
hard_header) and a 16 bit field that contains misc other information.
So, 32 bits, plus the data.  The hardware provides things like length,
and CRC checking.

Currently I'm setting dev->hard_header_len to 4.

The part that concerns me is what I set dev->type, dev->addr_len and
dev->flags to.

We don't technically have a hardware address so I set dev->addr_len to 0.

I set dev->type to ARPHRD_VOID, simply because I'm not sure what the
consequences of setting it to anything else are.

I set dev->flags to IFF_POINTOPOINT | IFF_NOARP

This appears to all work correctly, however both ifconfig and tcpdump
aren't really happy.

TCPDUMP doesn't know what to do with the ARPHRD_VOID and drops to 'raw'
mode, so it still does what I need, even if it prints an annoying
message for each packet.

ifconfig isn't sure what to do about the HWaddr.  For instance, this is
the ifconfig for one of the links:


hssl0     Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
            inet addr:192.168.2.1  P-t-P:192.168.2.2  Mask:255.255.255.255
            UP POINTOPOINT RUNNING NOARP  MTU:1500  Metric:1
            RX packets:3509748 errors:459 dropped:0 overruns:0 frame:363
            TX packets:3013210 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:100
            RX bytes:368907445 (351.8 Mb)  TX bytes:266074976 (253.7 Mb)

Any thoughts, comments or otherwise on what I've done, or what I
/should/ be doing would be appreciated as I'm still not fully across how
the networking stuff works.

Bill

-- 
Bill Leckey - Senior Software Design Engineer
TPG Research and Development
Ph: +61 2 62851711
Fax: +61 2 62853939


.
