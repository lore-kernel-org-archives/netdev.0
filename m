From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 2851] New: System takes 100% CPU and kernel
 log has *loads* of assertions
Date: Tue, 8 Jun 2004 17:04:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608170427.51615bde.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: atlaste@yahoo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 8 Jun 2004 16:44:13 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 2851] New: System takes 100% CPU and kernel log has *loads* of assertions


http://bugme.osdl.org/show_bug.cgi?id=2851

           Summary: System takes 100% CPU and kernel log has *loads* of
                    assertions
    Kernel Version: 2.6.6
            Status: NEW
          Severity: high
             Owner: niv@us.ibm.com
         Submitter: atlaste@yahoo.com


Distribution:Debian
Hardware Environment:

Small piece of lspci:
0000:02:05.0 Ethernet controller: Marvell Yukon Gigabit Ethernet 
10/100/1000Base-T Adapter (rev 13)
0000:02:0a.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 
05)

Furthermore, it's an intel ich-5r motherboard from ASUS: P4P800E-deluxe
(http://www.asus.com/prog/spec.asp?m=P4P800-E%20Deluxe&langs=01)

The first ethernet controller appears to be causing the problem. However, it 
should be noted that the first ethernet controller is used way more often, 
while the latter is merely used for internal traffic.

The first ethernet controller is on a LAN with 1500+ computers. This also means 
weird stuff could be happening here, although I think that's unlikely in this 
case, when looking at when the problems are occurring.

Software Environment:
Nothing special, running a number of services.

Problem Description:
The log should provide enough information. Somehow it appears SSHD causes the 
problem, perhaps in combination with a screen, and it is caused at arbitrary 
times. (about 2 times a day sometimes). This is just a small snippet; my entire 
HD ran full with 50GB of logs because of this bug, in merely two hours.

May 24 12:34:28 swing kernel: KERNEL: assertion (flags & MSG_PEEK) failed at 
net/ipv4/tcp.c (1571)
May 24 12:34:28 swing kernel: KERNEL: assertion (tp->copied_seq == tp->rcv_nxt 
|| (flags & (MSG_PEEK | MSG_TRUNC))) failed at
 net/ipv4/tcp.c (1635)
May 24 12:34:28 swing kernel: KERNEL: assertion (flags & MSG_PEEK) failed at 
net/ipv4/tcp.c (1571)
May 24 12:34:28 swing kernel: KERNEL: assertion (tp->copied_seq == tp->rcv_nxt 
|| (flags & (MSG_PEEK | MSG_TRUNC))) failed at
 net/ipv4/tcp.c (1635)
May 24 12:34:28 swing kernel: KERNEL: assertion (flags & MSG_PEEK) failed at 
net/ipv4/tcp.c (1571)
May 24 12:34:28 swing kernel: KERNEL: assertion (tp->copied_seq == tp->rcv_nxt 
|| (flags & (MSG_PEEK | MSG_TRUNC))) failed at
 net/ipv4/tcp.c (1635)
May 24 12:34:28 swing kernel: KERNEL: assertion (flags & MSG_PEEK) failed at 
net/ipv4/tcp.c (1571)
May 24 12:34:28 swing kernel: KERNEL: assertion (tp->copied_seq == tp->rcv_nxt 
|| (flags & (MSG_PEEK | MSG_TRUNC))) failed at
 net/ipv4/tcp.c (1635)


Steps to reproduce:

Not entirely sure. Usually I login with SSH and the bug arbitrarily emerges.

As a last note: 2.6.4 appeared to have this problem too.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
