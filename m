From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 0/3] Control VF link state
Date: Sun,  9 Jun 2013 16:27:12 +0300
Message-ID: <1370784435-26055-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46942 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753833Ab3FIN0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 09:26:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following the RFC sent couple of weeks ago, sending the patches which add API and 
implementation that lets the admin to configure the link state of the VF / SRIOV 
eSwitch vPORT. Basically, it has three states

Auto - VF link state reflects the PF link state (default)

Up - VF link state is up, traffic from VF to VF works even if
the actual PF link is down

Down - VF link state is down, no traffic from/to this VF, can be of
use while configuring the VF

Rony and Or.

changes from V0:
 - added missing part to the iproute2 patch which has the modification
   to the link show which display the VF link info (sorry for the spam).

changes from the RFC:
 - enhanced the get_vf_config ndo and linklink related code to 
   retrieve the VF link info too
 - same for iproute2


Rony Efraim (2):
  net/core: Add VF link state control
  net/mlx4: Add VF link state support

 drivers/net/ethernet/mellanox/mlx4/cmd.c       |   48 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    8 ++++
 drivers/net/ethernet/mellanox/mlx4/eq.c        |    9 +++-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    8 ++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |    1 +
 include/linux/if_link.h                        |    1 +
 include/linux/mlx4/cmd.h                       |    2 +-
 include/linux/netdevice.h                      |    3 +
 include/uapi/linux/if_link.h                   |   13 ++++++
 net/core/rtnetlink.c                           |   18 ++++++++-
 10 files changed, 106 insertions(+), 5 deletions(-)

iproute2 part:

Rony Efraim (1):
  Add VF link state control

 include/linux/if_link.h |   13 +++++++++++++
 ip/ipaddress.c          |   23 +++++++++++++++++++++++
 ip/iplink.c             |   14 ++++++++++++++
 3 files changed, 50 insertions(+), 0 deletions(-)
