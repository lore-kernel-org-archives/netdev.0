From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4131] New: iptables rules don't work correctly
 in 2.6.11-rc2-bk7
Date: Sat, 29 Jan 2005 23:48:32 -0800
Message-ID: <20050129234832.53c6f763.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: selecter@spray.se
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sat, 29 Jan 2005 23:46:15 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4131] New: iptables rules don't work correctly in 2.6.11-rc2-bk7


http://bugme.osdl.org/show_bug.cgi?id=4131

           Summary: iptables rules don't work correctly in 2.6.11-rc2-bk7
    Kernel Version: 2.6.11-rc2-bk7
            Status: NEW
          Severity: high
             Owner: laforge@gnumonks.org
         Submitter: selecter@spray.se


I am using vanilla kernel 2.6.10 as stable one. I got script that run on every
system startup:

#!/bin/bash

for table in INPUT OUTPUT FORWARD ; do
        iptables -P $table DROP
done

iptables -F
iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -p ALL -j ACCEPT

iptables -A OUTPUT -p ALL -j ACCEPT

On 2.6.10 NETWORK is accessible.
On 2.6.11-rc2-bk7 NETWORK is __NOT__ accessible (just after flushing iptables
and setting ACCEPT on INPUT and OUTPUT I got connection)

# iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables: No chain/target/match by that name

Was used the same kernelconfig. Gonna check again

cat /proc/net/ip_tables* | grep state returns nothing

Also I can't see connection state match support in menuconfig

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
