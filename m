From: Peter Bieringer <pb@bieringer.de>
Subject: Debug kernel network hook chain or why has Check Point
 Firewall module problems with IPv6
Date: Mon, 22 Apr 2002 08:47:13 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <22830000.1019458033@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi,

I found a for me strange issue and need help to dig a little bit into
because I'm running out of knowledge.

Pls. don't comment the use of commercial firewalls on Linux ;-)


Running a Check Point Firewall (NG FP-2) on Linux (RHL kernel
2.4.9-31, OpenSSH 2.9 and 3.1) this loads its big firewall module
into the kernel. 


First question: 
how can I check, which kernel network hooks it use? Are there any
tools available?


Now further on...


"No problem" scenario:
Linux is IPv4-only, openssh bound to 0.0.0.0, incoming SSH traffic is
accepted and CP state table is updated


"Problematic" scenario:
Linux has ipv6 module loaded, openssh bound to ::, now following
happen:

incoming SSH traffic (still IPv4) is accepted, CP updates the initial
connection timer but never update its state table to state
"established". The initial timer is still updated after each
keystroke, but if timeout occurs (default 60s), the connection will
break.

Looks like CP never sees (or recognizes) packets leaving the
firewalled host from a dual-stack application.


Second question:
Can I trace such issues? Is there a toolset available which shows me
which way a packet run in network kernel?


BTW: incoming SSH traffic via IPv6 is completly unrecognized and
therefore quietly accepted. Looks like CP never sees or recognize
incoming IPv6 packets at all - same issue, if on a IPv4-netfiltererd
box the IPv6-netfilter was forgotten...

TIA,
        Peter
