From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3746] New: Bridge causes machine lockups
Date: Mon, 15 Nov 2004 12:20:46 -0800
Message-ID: <20041115122046.1413527e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 15 Nov 2004 04:33:51 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3746] New: Bridge causes machine lockups


http://bugme.osdl.org/show_bug.cgi?id=3746

           Summary: Bridge causes machine lockups
    Kernel Version: 2.6.9
            Status: NEW
          Severity: high
             Owner: acme@conectiva.com.br
         Submitter: alchemyx@uznam.net.pl


Distribution: Gentoo 2004.2 with vanilla kernel sources
Hardware Environment: 2 x Xeon 2.80 GHz, 1GB RAM, 4 x e1000 NIC, 2 x e100 NIC
Software Environment: bridge-utils-0.9.6, bridged 2x e100 and 3x e1000
Problem Description:

On my Linux box I have few scripts that modify entries in ebtables filtering
chains. I have main chain called BLOCKED and in FORWARD chain I have entry "-j
BLOCKED", which directs every bridged packet to BLOCKED chain. Blocked chain
consists of entries:

-s SO:ME:MA:CA:DD:R0 -j DROP
-d SO:ME:MA:CA:DD:R0 -j DROP
[... about 50 of them ...]
-j RETURN

It works fine. About twenty or thirty times a day, a script does 'iptables -F
BLOCKED' and writes new entries into chain BLOCKED. Problem is that machine dies
from time to time (under heavy network load it happens once a day). It just
locks, nothing happenes, no oopses, or entries in logs. Then after 60 seconds,
watchdog from Intel motherboard resets machine.

Also I was doing some changes manually into chains and noticed that machine died
after I have issued 'ebtables -F BLOCKED' (clearing the chain). Once again after
60 seconds watchdog reset machine.

Problem is present in 2.6.8.1 and 2.6.9 kernels. There was no such problem on
2.4.26.

The only weird thing I noticed is when I initalise my bridge, is something about
that it can't get speed of some interfaces (guessing it is about e1000). I can't
give you full error message at the moment, because those have been rotated by
logrotate.

Steps to reproduce:

1. Set up a bridge consisting of few devices and having chains as described in
"Problem description"
2. Use high flow trough those devices (at least 50 megabits per second cumulative).
3. Change chain BLOCKED few tens of time a day.
4. Wait for lockup.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
