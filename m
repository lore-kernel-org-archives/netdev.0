From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Not all tcp sockets are found by ss command (iproute2)
Date: Thu, 07 Oct 2004 09:53:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4164F60C.6080807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all

I sent this message 2 days ago on linux-net@vger but got no answer yet. 
Maybe this list is a better place ?

I have two oddities with ss command (from iproute2 package)

linux kernel 2.6.8.1, SMP on x86_64
ss -V
ss utility, iproute2-ss040823

1) It seems TCP sockets in SYN-RECV are not displayed at all.

ss state syn-recv
Recv-Q Send-Q                                     Local Address:Port 
                                   Peer Address:Port

<nothing>

2) It seems not all tcp sockets are fetched/displayed on a very loaded 
server.

# ss -an|wc -l ; cat /proc/net/sockstat
  565859
sockets: used 611269
TCP: inuse 613140 orphan 2572 tw 4747 alloc 613820 mem 116376
UDP: inuse 7
RAW: inuse 0
FRAG: inuse 1 memory 544

You can see on this sample that ss -an displayed 565859 lines, but 
/proc/net/sockstat correctly said that more sockets were used.

Of course, /proc/net/tcp on such machine is not an option (never 
completes), so I cant list all connections for this machine. I really 
*need* a working ss command.

Are they known problems ?

Thank you
