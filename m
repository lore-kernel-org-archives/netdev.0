From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 1176] New: icmp redirect shuts connexions
Date: Tue, 2 Sep 2003 09:37:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902093742.20ea5d2d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mcousin@sigma.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 2 Sep 2003 08:49:47 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 1176] New: icmp redirect shuts connexions


http://bugme.osdl.org/show_bug.cgi?id=1176

           Summary: icmp redirect shuts connexions
    Kernel Version: 2.6.0-test4
            Status: NEW
          Severity: normal
             Owner: bugme-janitors@lists.osdl.org
         Submitter: mcousin@sigma.fr


Distribution: Gentoo 
Hardware Environment: PIV 1.7 GHz - 1Gb ns83820 network adapter 
Software Environment: 2.6.0-test4. gcc version 3.3.1  (Gentoo Linux 3.3.1, 
propolice). glibc 2.3.2. 
Problem Description: 
Connection are dropped every time I get an icmp_redirect 
 
Steps to reproduce: 
Log into a server using the wrong router as your default route. You get an 
icmp redirect, and manage to connect. At the next icmp_redirect you receive, 
connexions are lost. 
 
I've tested this with having an IRC connexion to the 'mercure' machine . 
 
After about 10 minutes, I see a new ICMP redirect arriving (the route cache 
has expired ?) 
 
64 bytes from mercure.sigma.fr (192.168.1.232): icmp_seq=501 ttl=252 
time=0.565 ms 
64 bytes from mercure.sigma.fr (192.168.1.232): icmp_seq=503 ttl=252 
time=0.575 ms 
>From 89.133.2.200: icmp_seq=504 Redirect Host(New nexthop: fwsigma.sigma.fr 
(89.133.2.1)) 
64 bytes from mercure.sigma.fr (192.168.1.232): icmp_seq=504 ttl=252 time=1.61 
ms 
64 bytes from mercure.sigma.fr (192.168.1.232): icmp_seq=505 ttl=252 
time=0.596 ms 
 
from route -C : 
 
before the redirect : 
marc root # route -C | grep mercure 
marc            mercure.sigma.f fwsigma.sigma.f       0      0        5 eth0 
mercure.sigma.f marc            marc            l     0      0        4 lo 
marc            mercure.sigma.f fwsigma.sigma.f       0      0      470 eth0 
marc            mercure.sigma.f fwsigma.sigma.f       0      2        5 eth0 
mercure.sigma.f marc            marc            l     0      0      525 lo 
 
after the redirect: 
marc root # route -C | grep mercure 
mercure.sigma.f marc            marc            l     0      0       18 lo 
marc            mercure.sigma.f fwsigma.sigma.f       0      0        6 eth0 
marc            mercure.sigma.f fwsigma.sigma.f       0      1        4 eth0 
 
 
my routing table: 
Kernel IP routing table 
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface 
89.0.0.0        *               255.0.0.0       U     0      0        0 eth0 
loopback        localhost       255.0.0.0       UG    0      0        0 lo 
default         89.133.2.200    0.0.0.0         UG    1      0        0 eth0 
 
My 'usual' route is via 89.133.2.200. To get to mercure, I have to get through 
'fwsigma' (89.133.2.1). 
 
As soon as I get the ICMP_REDIRECT packet, the connexion to the IRC server is 
lost. 
When I add a static route to mercure via fwsigma, the problem disappears...

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
