From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4158] New: bridge always takes the mac i don't
 want
Date: Thu, 3 Feb 2005 17:17:58 -0800
Message-ID: <20050203171758.4805879c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel26@dush.student.utwente.nl
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 3 Feb 2005 16:59:05 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4158] New: bridge always takes the mac i don't want


http://bugme.osdl.org/show_bug.cgi?id=4158

           Summary: bridge always takes the mac i don't want
    Kernel Version: 2.4+
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: kernel26@dush.student.utwente.nl


Problem Description:
in some situations your bridge needs to take the mac address of one certain 
interface. in my case the isp checks my mac address. currently it is not 
possible to choose which mac the bridge takes.
i changed the code somewhat to make it possible to choose the mac of the bridge 
by changing the order in which you add interfaces to the bridge. please 
consider changing this in the kernel.

code: net/bridge/br_stp_if.c:156
  if (addr == br_mac_zero ||
      memcmp(p->dev->dev_addr, addr, ETH_ALEN) < 0)
    addr = p->dev->dev_addr;
 
please change it to:
  if (addr == br_mac_zero)
    addr = p->dev->dev_addr;

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
