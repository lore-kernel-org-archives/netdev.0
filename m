From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH 0/4 net-next] enic: add devcmd2
Date: Sun, 16 Aug 2015 01:44:50 +0530
Message-ID: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Cc: nalreddy@cisco.com, ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:49949 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753332AbbHOUPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Aug 2015 16:15:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds new devcmd2 support. The first two patches are code
refactoring.

devcmd is an interface for driver to communicate with fw/adaptor. It
involves writing data to hardware registers and waiting for the result.
This mechanism does not scale well. The queuing of "no wait" devcmds is
done in firmware memory rather than on the host. Firmware memory is a
rather more scarce and valuable resource than host memory. A devcmd storm
from one vf can disrupt the service on other pf/vf. The lack of flow
control allows for possible denial of server from one VM to another.
Devcmd2 uses work queue to post the devcmds, just like tx work queue. This
allows better flow control.

Govindarajulu Varadarajan (4):
  enic: move struct definition from .c to .h file
  enic: use netdev_<foo> or dev_<foo> instead of pr_<foo>
  enic: add devcmd2 resources
  enic: add devcmd2

 drivers/net/ethernet/cisco/enic/enic.h          |  21 +-
 drivers/net/ethernet/cisco/enic/enic_main.c     |   5 +
 drivers/net/ethernet/cisco/enic/vnic_cq.c       |   3 +-
 drivers/net/ethernet/cisco/enic/vnic_dev.c      | 275 ++++++++++++++++++------
 drivers/net/ethernet/cisco/enic/vnic_dev.h      |  44 +++-
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h   |  28 +++
 drivers/net/ethernet/cisco/enic/vnic_intr.c     |   3 +-
 drivers/net/ethernet/cisco/enic/vnic_resource.h |   7 +
 drivers/net/ethernet/cisco/enic/vnic_rq.c       |   6 +-
 drivers/net/ethernet/cisco/enic/vnic_wq.c       |  31 ++-
 drivers/net/ethernet/cisco/enic/vnic_wq.h       |  17 ++
 11 files changed, 357 insertions(+), 83 deletions(-)

-- 
2.5.0
