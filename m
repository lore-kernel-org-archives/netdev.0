From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (0/13) appletalk bug fixes
Date: Fri, 29 Aug 2003 13:51:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829135119.78d98961.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Started out just converting aarp to use seq_file, and getting my
old "new protocol" patch tested.  In the process ran into a bunch
of races relating to module unload.  This set addresses:

1. Setting owner field on DDP sockets (bug)
2. Invert logic on release (readability)
3. Align headers with columns (cosmetic)
4. Keep track of last sent
5. Purge aarp entries on unload (bug)
6. aarp deltimer_sync
7. aarp convert to seq_file
8. set owner on /proc/net/atalk directory
9. Update comment in DDP about modules
10. Orphan DDP sockets on destroy (bug)
11. Change /proc/net/aarp to /proc/net/atalk/arp
12. Keep netdevice references for pointers held
13. Update DDP to new protocol format

These have been tested on 2.6.0-test4 by running a ethertalk
between the SUT and a reference 2.4 system.
