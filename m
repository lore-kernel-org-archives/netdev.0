From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 0/3] qlcnic: Bug fixes
Date: Mon, 4 Aug 2014 11:51:15 -0400
Message-ID: <1407167478-22277-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:65250 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752120AbaHDQXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 12:23:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series contains following bug fixes.

* Aggregating tx stats in adapter variable was resulting
  in increase of stats when user runs ifconfig command
  and no traffic is running. Instead aggregate tx stats
  in local variable and then assign it to adapter struct
  variable.
* Set_driver_version was called after registering netdev
  which was resulting in a race between FLR in open
  handler and set_driver_version command as open handler
  can be called simulatneously on another cpu even if probe
  is not complete. So call this command before registering
  netdev.
* dcbnl_ops should be initialized before registering netdev
  as they are referenced in open handler.
   
Please apply this series to net.

Thanks,
Rajesh

Rajesh Borundia (3):
  qlcnic: Fix update of ethtool stats.
  qlcnic: Set driver version before registering netdev
  qlcnic: Initialize dcbnl_ops before register_netdev

 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   18 +++++++++++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   10 +++++-----
 3 files changed, 19 insertions(+), 11 deletions(-)
