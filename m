From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 00/17] drivers: hv: kvp
Date: Tue, 24 Jul 2012 09:01:12 -0700
Message-ID: <1343145672-3641-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	olaf@aepfle.de, apw@canonical.com, netdev@vger.kernel.org,
	ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset expands the KVP (Key Value Pair) functionality to
implement the mechanism to GET/SET IP addresses in the guest. This
functionality is used in Windows Server 2012 to implement VM
replication functionality. The way IP configuration information
is managed is distro specific. Based on the feedback I have gotten
from Olaf, Greg, Steve, Ben and Mairus, I have chosen to seperate
distro specific code from this patch-set. Most of the GET operation
can be implemented in a way that is completely distro independent and
I have implemented that as such and is included in this patch-set.
Some of the attributes that can only be fetched in a distro
dependent way as well the mechanism for configuring an interface
(the SET operation) that is clearly distro specific is to be
implemented via external scripts that will be invoked via the KVP
code. We define here the interface to these scripts.

Adding support for IP injection resulted in some changes to the
protocol between the user level daemon and the kernel driver.
These changes have been implemented in way that would retain
compatibility with older daemons. I would like to thank Olaf and
Greg for pointing out the compatibility issue.

K. Y. Srinivasan (17):
  Drivers: hv: vmbus: Use the standard format string to format GUIDs
  Drivers: hv: Add KVP definitions for IP address injection
  Drivers: hv: kvp: Cleanup error handling in KVP
  Drivers: hv: kvp: Support the new IP injection messages
  Tools: hv: Prepare to expand  kvp_get_ip_address() functionality
  Tools: hv: Further refactor kvp_get_ip_address()
  Tools: hv: Gather address family information
  Tools: hv: Gather subnet information
  Tools: hv: Represent the ipv6 mask using CIDR notation
  Tools: hv: Gather ipv[4,6] gateway information
  Tools: hv: Gather DNS information
  Tools: hv: Gather DHCP information
  Tools: hv: Implement the KVP verb - KVP_OP_SET_IP_INFO
  Tools: hv: Rename the function kvp_get_ip_address()
  Tools: hv: Implement the KVP verb - KVP_OP_GET_IP_INFO
  Tools: hv: Get rid of some unused variables
  Tools: hv: Correctly type string variables

 drivers/hv/hv_kvp.c      |  251 +++++++++++--
 drivers/hv/hv_util.c     |    4 +-
 drivers/hv/vmbus_drv.c   |   38 +--
 include/linux/hyperv.h   |   88 ++++-
 tools/hv/hv_kvp_daemon.c |  943 +++++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 1160 insertions(+), 164 deletions(-)

-- 
1.7.4.1
