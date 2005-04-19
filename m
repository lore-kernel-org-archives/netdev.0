From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: [Bug 3998] ARP issues after RC1
Date: Tue, 19 Apr 2005 11:00:18 +1000
Message-ID: <20050419110018.25baf191@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 18 Apr 2005 05:39:42 -0700
From: bugme-daemon@osdl.org
To: shemminger@osdl.org
Subject: [Bug 3998] ARP issues after RC1


http://bugme.osdl.org/show_bug.cgi?id=3998

----------
Distribution: Redhat 9.0

Hardware Environment: Intel/IWill MBs. Intel e1000 and Broadcom tg3 network modules.

Problem Description: After upgrading to 2.4.28, we having issues where hosts are
unreachable and we are getting <incomplete> entries in the ARP tables. After the
entry has cleared, the host will become reachable. This is most noticible upon
startup, where netfs (nfs mounts), yp, and ntp fail, as they cannot reach their
corresponding servers. This is happening on multiple machines, with different
MBs and network interfaces, all running RedHat 9.0. 2.4.27, using the same
.config had no such issues. After compiling all the pre and rc patches, it seems
that the offending change occurred between rc1 and rc2.

Steps to reproduce:

1. Install RH9, workstation install.
2. Configure NFS mounts in /etc/fstab, chkconfig netfs on.
3. Configure NTP, chkconfig ntp on.
4. Configure YP, chkconfig ypbind on.
5. Compile 2.4.28 using .config below
6. Reboot using 2.4.28. Upon boot, the services above will fail, as they cannot
reach their servers.
7. Once up, log in as root and type arp -a. There will be <incomplete> entries
for the unreachable hosts.
8. Compile 2.4.28-rc1, using the same .config.
9. Reboot using 2.4.28-rc1. All the previously failing services will start up
with no issues.
10. Compile 2.4.28-rc2, using the same .config.
11. Reboot using 2.4.28-rc2. The services will fail once again.
