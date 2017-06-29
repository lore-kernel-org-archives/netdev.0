From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH 0/2] i40e/i40evf: fix override of administratively set MAC address in trusted mode
Date: Thu, 29 Jun 2017 15:12:23 +0200
Message-ID: <20170629131225.9251-1-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3273 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751729AbdF2NNR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 09:13:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In trusted mode VFs should be able to override the administratively set MAC
address. This is currently not possible as i40evf returns -EPERM if an
administratively set MAC is present, for MAC change requests.

First patch renames vf_offload_flags to vf_cap_flags to make it more generic.
Second patch then adds a flag to vf_cap_flags to give the VF information on
whether it runs in trusted mode and makes use of the flag in i40evf.

Patches are against jkirshers dev-queue branch.

Stefan Assmann (2):
  i40e/i40evf: rename vf_offload_flags to vf_cap_flags in struct
    virtchnl_vf_resource
  i40e/i40evf: add virtchnl flag to indicate trusted VF

 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 25 ++++++++++++----------
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  2 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         | 10 ++++-----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 15 +++++++------
 include/linux/avf/virtchnl.h                       |  5 +++--
 5 files changed, 31 insertions(+), 26 deletions(-)

-- 
2.9.4
