From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3657] New: downed interfaces acting as aliases
Date: Thu, 28 Oct 2004 23:46:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028234649.2d4ed3b8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mbm@alt.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 28 Oct 2004 23:45:02 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3657] New: downed interfaces acting as aliases


http://bugme.osdl.org/show_bug.cgi?id=3657

           Summary: downed interfaces acting as aliases
    Kernel Version: 2.6.8.1
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: mbm@alt.org


An interface will still reply while down, acting as an ip alias if any other
adapters have a compatible subnet.

Scenerio:

Using a laptop on a wired network, 192.168.1.0/24 subnet, eth0 set to
192.168.1.2. Moved to a different network on wireless, also a 192.168.1.0/24. 

The ethernet is still configured for 192.168.1.2 but the interface is down
(ifconfig eth0 down); wireless clients on the second network are now having
issues, 192.168.1.2 requests are going to the laptop.

To confirm the issue, eth0 is changed to 192.168.1.254 and brought down again
(an ip not in use on the wireless network). All wireless clients are magically
able to ping 192.168.1.254.


Steps to reproduce:

ifconfig eth0 10.1.2.3 (or any random nonroutable ip)
ifconfig eth0 down
ping 10.1.2.3

.. wtf, how did it get a reply from a down'd interface?

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
