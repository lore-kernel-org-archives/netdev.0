From: Gandalf The White <gandalf@digital.net>
Subject: Fragmentation Attack
Date: Sat, 07 Feb 2004 11:36:14 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BC4A7E2E.E256%gandalf@digital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux IPStack <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Greetings and Salutations:

I have been directed to this mailing list for discussion of something I
worked on.  I am hoping that given the specifics that the Linux OS can be
fine tuned to fix this issue.

I recently received my GCFW (GIAC Certified Firewall Analyst) certification
from SANS.  Part of the certification requires completing a "practical", a
security paper.  In the certification we are required to "attack" another
practical that has been previously passed.  While working on this portion of
the paper I came up with (I believe) a unique DoS (Denial Of Service) attack
that affects the operation of most operating systems, but in this case we
are discussing Linux.

The "Rose" attack (as I call it) is described at:
http://digital.net/~gandalf/Rose.rtf

A summary of the attack:
1) The first (very small, 30 bytes) fragment of a ICMP packet is sent.  This
is offset 0 with the complete and correct ICMP header
2) The last fragment (again, very small) of a 64k sized fragment is sent.
3) This process is repeated with a UDP packet and a TCP packet

The end result is that on my 450 MHz Linux box the CPU utilization went to
100% utilization.  I had a fragmented ping from another computer running at
the same time, most fragmented pings were replied to, a few were missed.
The Linux box I was "attacking" returned to normal when I stopped the
attack.

The other interesting feature of this attack that I have seen is that the
source IP address and the source and destination port do not matter.  On any
device.  Since the packet is never fully assembled the upper levels of the
IP stack never validate that the destination port is valid.

I also noticed that different machines handled the ICMP reassembly Time
Required error packet differently, thus this could be used for OS
fingerprinting.

I have cleaned up (revisited) the attack since I wrote the paper.  As
written the original will work the same as my cleaned up version (but below
is the "technically correct" version).  I fixed my input into the nemesis
program (as written in the above paper) as follows.
See http://www.packetfactory.net/projects/nemesis/ for the software:
nemesis icmp -S 10.3.64.121 -D 172.16.1.100 -d1 -i 8 -I 7242 -P
Picmpdata.txt -FM0
nemesis ip -S 10.3.64.121 -D 172.16.1.100 -d1 -I 7242 -p 1 -P Picmpdata.txt
-F8100
nemesis tcp -S 10.196.212.207 -D 172.16.1.100 -d1 -I 2153 -s 2494456820 -x
36961 -y 63398 -P Ptcpdata.txt -FM0
nemesis ip -S 10.196.212.207 -D 172.16.1.100 -d1 -I 2153 -p 6 -P
Ptcpdata.txt -F8100
nemesis udp -S 10.195.74.172 -D 172.16.1.100 -d1 -I 6316 -x 13253 -y 20460
-P Pudpdata.txt -FM0
nemesis ip -S 10.195.74.172 -D 172.16.1.100 -d1 -I 6316 -p 17 -P
Pudpdata.txt -F8100

For testing I generated a Excel spreadsheet to put random values for many of
the fields above (source IP, Sport, Dport) and thousands of packets to test
against the Linux box. I ran the test using nemesis (which is, of course,
too slow to affect the Linux box) and captured the packets using netwox54 :
See http://www.laurentconstantin.com/en/netw/netwox/ for netwox.

After that had finished running for about 9 hours or so I was able to dump
the captured packets back out all at one time using netwox54 again.  This is
where the DoS took place, throwing all those packets at the box at once.

If you want step by step instructions I can provide them.

This is FYI, I am hoping that protection against this attack can be found.

Ken

---------------------------------------------------------------
Do not meddle in the affairs of wizards for they are subtle and
quick to anger.
Ken Hollis - Gandalf The White - gandalf@digital.net - O- TINLC
WWW Page - http://digital.net/~gandalf/
Trace E-Mail forgery - http://digital.net/~gandalf/spamfaq.html
Trolls crossposts - http://digital.net/~gandalf/trollfaq.html
