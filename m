From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH RFC 0/2] Control VF link state
Date: Wed,  8 May 2013 16:45:14 +0300
Message-ID: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
Cc: amirv@mellanox.com, ronye@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog124.obsmtp.com ([207.126.144.157]:56338 "EHLO
	eu1sys200aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754585Ab3EHNpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 09:45:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a suggestion for API and implementation that lets the admin to configure
the link state of the VF / SRIOV eSwitch vPORT. Basically, it has three states

Auto -	the VF link state will reflect the PF link state

Enable - VF link stat will be always up, traffic from VF to VF can 
	 work even if PF link is down.

Disable - VF link state is down and the VF can't send/recv, e.g can be 
  	  used to suspend the link while configuring the VF.

Rony and Or.

Rony Efraim (2):
  net/core: Add netlink directives to control VF link state
  net/mlx4: Add vf link state support

 drivers/net/ethernet/mellanox/mlx4/cmd.c       |   47 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    8 ++++
 drivers/net/ethernet/mellanox/mlx4/eq.c        |    9 ++++-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    8 ++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |    1 +
 include/linux/mlx4/cmd.h                       |    2 +-
 include/linux/netdevice.h                      |    3 ++
 include/uapi/linux/if_link.h                   |   13 +++++++
 net/core/rtnetlink.c                           |    9 +++++
 9 files changed, 97 insertions(+), 3 deletions(-)

Rony Efraim (1):
  Add VF link state control 

iproute2 diffstat:

 include/linux/if_link.h |   13 +++++++++++++
 ip/iplink.c             |   14 ++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)
