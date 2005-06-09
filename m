From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: TCP stalls, 2.6.12pre6
Date: Fri, 10 Jun 2005 00:58:55 +0200
Message-ID: <m3mzpz87dc.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I got this three times recently, with 2.6.12 pre6 and possibly pre5 (4?)
kernels on both sides:

intrepid is X11-server with ssh connection to defiant (X11-forwarding,
EPIC100 PCI NIC). defiant is an older notebook machine and it was running
XEmacs and Firefox with ssh/X11 (cardbus DEC 21143).
Both on the same Ethernet subnet. Both standard MTU etc.


intrepid# netstat -to

tcp 0 0 intrepid:3457 defiant:ssh  ESTABLISHED keepalive (5615.71/0/0)


defiant# netstat -to (not 100% sure about this data)

      Send-Q
tcp 0 32800 defiant:ssh intrepid:3457  ESTABLISHED keepalive (20.5/0/0)



Partial dump:

intrepid# tcpdump -r qwe -vve port not 4840

00:08:32.603003 len 1514: IP (tos 0x10, ttl  64, id 17467, offset 0,
   flags [DF], proto 6, length: 1500) defiant.ssh > intrepid.3457: .
   [bad tcp cksum 2fa (->8fbe)!] 2999401769:2999403217(1448)
   ack 1597770543 win 16022 <nop,nop,timestamp 131339306 29183805>

00:08:55.750326 len 158:  IP (tos 0x10, ttl  64, id 13187, offset 0,
   flags [DF], proto 6, length: 144) intrepid.3457 > defiant.ssh: P
   [tcp sum ok] 1:81(80) ack 0 win 18856 <nop,nop,timestamp 29224727
   131133680,nop,nop,sack sack 1 {1448:16816} >

00:08:55.750603 len 66:   IP (tos 0x10, ttl  64, id 17469, offset 0,
   flags [DF], proto 6, length: 52) defiant.ssh > intrepid.3457: .
   [tcp sum ok] 16816:16816(0) ack 81 win 16022 <nop,nop,timestamp
   131362456 29224727>

Send-Q is stuck at the fixed value. Other TCP connections (including
similar ones between the two hosts) are not affected.


Ideas?
-- 
Krzysztof Halasa
