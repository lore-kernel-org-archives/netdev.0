From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/17] mlxsw: Introduce support for Data Center Bridging
Date: Wed,  6 Apr 2016 17:09:59 +0200
Message-ID: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33268 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbcDFPKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:21 -0400
Received: by mail-wm0-f68.google.com with SMTP id i204so14155778wmd.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

This patchset introduces support for Quality of Service (QoS) as part of the
IEEE Data Center Bridiging (DCB) standards.

Patches 1-9 do the required device initialization. Specifically, patches 1-6
initialize the ports' headroom buffers, which are used at ingress to store
incoming packets while they go through the switch's pipeline. Patches 7-9
complete them by initializing the egress scheduling.

The pipeline mentioned above determines the packet's egress port(s) and
traffic class. Ideally, once out of the pipeline the packet moves to the
switch's shared buffer (to be introduced in Jiri's patchset, currently
default values are used) and scheduled for transmission according to its
traffic class. The egress scheduling is configured according to the 802.1Qaz
standard, which is part of the DCB infrastructure supported by Linux. This
is introduced in patches 10-12.

Even after going through the pipeline packets are not always eligible to
enter the shared buffer. This is determined by the amount of available space
and the quotas associated with the packet. However, if flow control is
enabled and the packet is associated with the lossless flow, then it will
stay in the headroom and won't be discarded. This is introduced in patches
13-17.

Please check individual commit messages for more info, as I tried to keep
them pretty detailed.

Thanks.

Ido Schimmel (17):
  mlxsw: reg: Add Port Prio To Buffer register
  mlxsw: spectrum: Map all switch priorities to priority group 0
  mlxsw: spectrum: Add bytes to cells helper
  mlxsw: spectrum: Correctly configure headroom size
  mlxsw: reg: Use correct PBMC register length
  mlxsw: spectrum: Set port's shared buffer size to 0
  mlxsw: reg: Add QoS ETS Element Configuration register
  mlxsw: reg: Add QoS Switch Traffic Class Table register
  mlxsw: spectrum: Initialize egress scheduling
  mlxsw: spectrum: Introduce support for Data Center Bridging (DCB)
  mlxsw: spectrum: Add IEEE 802.1Qaz ETS support
  mlxsw: spectrum: Allow setting maximum rate for a TC
  mlxsw: reg: Add Port Flow Control Configuration register
  mlxsw: reg: Add lossless settings for PBMC register
  mlxsw: spectrum: Add support for PAUSE frames
  mlxsw: reg: Introduce per priority counters
  mlxsw: spectrum: Add IEEE 802.1Qbb PFC support

 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   8 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |   1 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 507 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 263 ++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  61 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 108 +++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c | 480 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |   3 +-
 8 files changed, 1381 insertions(+), 50 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c

-- 
2.5.5
