From: "Luis R. Rodriguez" <mcgrof@frijolero.org>
Subject: First compat-wireless based on v3.2
Date: Mon, 9 Jan 2012 17:35:26 -0800
Message-ID: <CAB=NE6UJo-uFBWa2C-DwRJ8OPck99-6jkh_NXHXdp==YRDZC=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:34272 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932270Ab2AJBfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 20:35:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Happy new years with v3.2. We have two compat-wireless releases ready
based on the final v3.2 Linus pushed out, a vanilla release [0] and
another one with patches pending for stable from linux-next.git sucked
out [1]. The "-s" postfix here annotates that pending-stable fixes
have been applied on top of the vanilla Linus release. For details on
changes you can refer to the ChangeLog-2.6.36-rc5-wireless [2], below
is the main contributions to the generic backport module compat, and
compat-wirless which uses compat. For more details of what this is
visit the stable compat-wireless releases page [3]. I send these out
from sunny Costa Rica :)

[0] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.2/compat-wireless-3.2-1.tar.bz2
[1] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.2/compat-wireless-3.2-1-s.tar.bz2
[2] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.2/ChangeLog-3.2-wireless
[3] http://wireless.kernel.org/en/users/Download/stable/

compat-wireless code metrics

    814603 - Total upstream lines of code being pulled
      2488 - backport code changes
      2143 - backport code additions
       345 - backport code deletions
      8670 - backport from compat module
     11158 - total backport code
    1.3697 - % of code consists of backport work
        63 - Code changes brought in from pending-stable
        47 - Code additions brought in from pending-stable
        16 - Code deletions brought in from pending-stable
    0.0077 - % of code being cherry picked from pending-stable

Base tree: linux-stable.git
Base tree version: v3.2
compat-wireless release: compat-wireless-v3.2-1-s

The list of pulled in pending-stable patches from linux-next.git are:

0001-wl12xx-Validate-FEM-index-from-ini-file-and-FW.patch
0002-wl12xx-Check-buffer-bound-when-processing-nvs-data.patch
0004-wl12xx-Restore-testmode-ABI.patch
0005-libertas-clean-up-scan-thread-handling.patch

Updates from the compat.git project:
====================================

git shortlog linux-3.1.y..linux-3.2.y

Felix Fietkau (1):
      compat: fix misplaced #ifdef for the workqueue backport

Hauke Mehrtens (20):
      compat: add round_down
      compat: add support for linux 3.1
      compat: pm_qos_params.h was renamed to pm_qos.h
      compat: add PMSG_IS_AUTO
      compat: add mac_pton()
      compat: add cordic lib
      compat: add crc8 lib
      compat: add __always_unused
      compat: add skb_frag_dma_map
      compat: add kstrtou8_from_user
      compat: add rcu_read_lock_held()
      compat: add lower_32_bits
      compat: add IS_ERR_OR_NULL()
      compat: add skb_tx_timestamp() and skb_defer_rx_timestamp()
      compat: add ETH_P_TDLS
      compat: add is_unicast_ether_addr
      compat: add linux/of.h just when CONFIG_OF is set.
      compat: backport system_nrt_wq
      comapt: add skb_frag_size() and hex_byte_pack()
      compat: add some workarounds for Debian squeeze

Johannes Berg (3):
      The led_lock is never initialised, so there     are
warnings/errors. It can also be made     static.
      Depending on the arguments to alloc_netdev_mqs(),     it may
give a warning due to the use of max().     Fix the warning with
max_t().
      compat: add skb_complete_wifi_ack & feature flag

John W. Linville (1):
      compat: avoid warning in compat_system_workqueue_create

Pavel Roskin (1):
      compat: provide INIT_WORK with 2 arguments for kernels before 2.6.20

Updates from the compat-wireless.git project:
=============================================

git shortlog linux-2.6.1.y..linux-3.2.y

Hauke Mehrtens (19):
      compat-wireless: ath6kl moved to main area.
      compat-wireless: do not build libertas_sdio for kernel < 2.6.32
      compat-wireless: adapt moving of ethernet drivers
      compat-wireless: add many fixes to driver-select
      comapt-wireless: make patches apply again
      compat-wireless: fix building with CONFIG_CFG80211_INTERNAL_REGDB
      compat-wireless: pm_qos_request_list was renamed to pm_qos_request
      compat-wireless: make patches apply again
      compat-wireless: make patches apply again
      compat-wireless: activate CONFIG_B43_PHY_HT
      compat-wireless: make patches apply again
      compat-wireless: remove old config options
      compat-wireless: make patches apply again.
      compat-wireless: make patches apply again
      compat-wireless: make patches apply again
      compat-wireless: deactivate sdio suspend in ath6kl with kernel < 2.6.34
      compat-wireless: make patches apply again
      compat-wireless: adapt moving brcm80211 to main area
      compat-wireless: backport rtlwifi PM

Johannes Berg (2):
      compat-wireless: make driver-select only select complete lines
      compat-wireless: add struct padding to fix wext issue

Luis R. Rodriguez (15):
      compat-wireless: refresh patches
      compat-wireless: refresh patches
      compat-wireless: fix multiqueue patch
      compat-wireless: update patches
      compat-wireless: refresh patches
      compat-wireless: refresh patches
      compat-wireless: refresh patches for next-20111108
      compat-wireless: refresh patches for v3.2-rc1
      compat-wireless: copy driver files only if present
      compat-wireless: fix patches/41-no-kfree-rcu.patch
      compat-wireless: refresh patches for v3.2-rc6
      compat-wireless: use linux-stable instead of linux-2.6-allstable
      compat-wireless: fix paths for pending-stable fixes
      compat-wireless: skip a stable patch
      compat-wireless: refresh patches for v3.2

  Luis
