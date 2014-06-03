From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Tue,  3 Jun 2014 00:45:02 -0700
Message-ID: <1401781509-6435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52586 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932130AbaFCHr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2014 03:47:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, igb and ixgbe.

Emil provides his version 2 fix for the detection of SFP+ capable inter=
faces.
In cases where the driver is loaded while there are no SFP+ modules in =
cage,
the interface was not being detected as SFP capable.  Resolve the issue=
 by
identifying interfaces with no PHY type set as SFP capable which allows=
 the
driver to detect the SFP module when the interface is brought up.  In t=
his
version 2 of the patch, the 82599 specific check was removed since we o=
nly
have 82598 devices that are SFP capable.

Jacob removes the including of the export header in the ixgbe PTP core,=
 since
it is not needed.  Renames igb_ptp_enable() to igb_ptp_feature_enable()=
 to
better reflect the actual functions purpose.

Todd fixes the ethtool loopback test for i354 backplane devices since w=
e
do not know what PHY is to be used for the devices, use MAC loopback fo=
r
ethtool tests.  Todd also sets the packet buffer size register defaults=
 for
i210 devices.

Yongjian Xu removes the check for skb->len being negative or zero since=
 there
is never a case where it would be zero or negative for e1000.

Manuel Sch=C3=B6lling updates e1000 to use the time_after() helper func=
tion.

The following are changes since commit a68ab98e6c7ab0955babcdc45ca44688=
6f3bfb25:
  fec: Include pinctrl header file
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next maste=
r

Emil Tantilov (1):
  ixgbe: fix detection of SFP+ capable interfaces

Jacob Keller (2):
  ixgbe: remove linux/export.h header from ixgbe_ptp.c
  igb: rename igb_ptp_enable to igb_ptp_feature_enable

Manuel Sch=C3=B6lling (1):
  e1000: Use time_after() for time comparison

Todd Fujinaka (2):
  igb: use mac loopback for i354 backplane
  igb: add defaults for i210 TX/RX PBSIZE

Yongjian Xu (1):
  e1000: remove the check: skb->len<=3D0

 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 3 ++-
 drivers/net/ethernet/intel/e1000/e1000_main.c    | 5 -----
 drivers/net/ethernet/intel/igb/e1000_defines.h   | 3 +++
 drivers/net/ethernet/intel/igb/e1000_regs.h      | 4 ++++
 drivers/net/ethernet/intel/igb/igb_ethtool.c     | 4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c        | 6 ++++++
 drivers/net/ethernet/intel/igb/igb_ptp.c         | 8 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 7 -------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     | 1 -
 10 files changed, 23 insertions(+), 20 deletions(-)

--=20
1.9.3
