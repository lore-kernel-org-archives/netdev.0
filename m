From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4119] New: no space left on device, when doing
 "cat /proc/net/ip_conntrack | wc -l"
Date: Fri, 28 Jan 2005 14:25:20 -0800
Message-ID: <20050128142520.19a91248.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Fri, 28 Jan 2005 11:46:35 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4119] New: no space left on device, when doing "cat /proc/net/ip_conntrack | wc -l"


http://bugme.osdl.org/show_bug.cgi?id=4119

           Summary: no space left on device, when doing "cat
                    /proc/net/ip_conntrack | wc -l"
    Kernel Version: 2.6.10
            Status: NEW
          Severity: normal
             Owner: laforge@gnumonks.org
         Submitter: philippe.malaise@laposte.net


Distribution: slackware
Hardware Environment: i386
Software Environment: linux
Problem Description: 

   After upgrading from 2.6.x to 2.6.10, after some days running, when the nat
table is filled with thousands of lines  , when you do a :

cat /proc/net/ip_conntrack | wc -l

You get a number of lines (currently between 22k and 23k), preceeded by the
message "No space left on device".
Note that the ip_conntrack_max parameter in the proc fs is set to 65535.
The problem appears randomly.
When doing a strace of the previous command, you see possibly a buffer overflow.

If you decrease the ip_conntrac_max value to 8192, the problem disappears.




Steps to reproduce:

- set the ip_conntrack_max parameter to 65535
- wait for some hours, opening a lot of connections recorded in the ip_conntrack
file ( proc fs )
- do a "wc -l" of the conntrack file
- you randomly get the error....

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
