From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4239] New: ARP sent with wrong MAC address
Date: Tue, 22 Feb 2005 11:32:40 -0800
Message-ID: <20050222113240.5e886c6a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: agulati@nextone.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 22 Feb 2005 07:31:58 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4239] New: ARP sent with wrong MAC address


http://bugme.osdl.org/show_bug.cgi?id=4239

           Summary: ARP sent with wrong MAC address
    Kernel Version: 2.6.10
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: agulati@nextone.com


Distribution:
Hardware Environment: P4
Software Environment: 2.6.10
Problem Description: Turning ARP OFF and sending something out from that
interface creates a NOARP entry in the ARP table which does not go away when you
turn ARP back ON.

ip link set eth0 arp off
ping -I eth0 1.1.1.1              (creates ARP entry with own MAC address --
1.1.1.1 dev eth0 lladdr <eth0's MAC address> nud noarp)

This entry in arp table with 'nud noarp', stays there even after turning ARP on.
ip link set eth0 arp on

And ping 1.1.1.1 doesn't work after that since it considers that 'nud noarp'
entry as valid and doesn't send ARP request but sends an ICMP request to its own
MAC address!

Shouldn't that entry be removed after enabling ARP on eth0?
If not, is there a way to remove that entry (I tried 'ip -statistics neigh flush
dev eth0 nud noarp', but that goes in a loop)

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
