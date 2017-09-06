From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 6 Sep 2017 16:27:15 -0700
Message-ID: <CA+55aFw0KNTKFrRHk5hthDGTGgL9BGt9G=x_m9Tz7m_-pN+NoA@mail.gmail.com>
References: <20170905.214143.826912481689443792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Linux Wireless List <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Luca Coelho <luciano.coelho@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33769 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbdIFX1Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 19:27:16 -0400
In-Reply-To: <20170905.214143.826912481689443792.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pull request completely breaks Intel wireless for me.

This is my trusty old XPS 13 (9350), using Intel Wireless 8260 (rev 3a).

That remains a very standard Intel machine with absolutely zero odd
things going on.

The firmware is iwlwifi-8000C-28.ucode from
iwl7260-firmware-25.30.13.0-75.fc26.noarch, and the kernel reports

  iwlwifi 0000:3a:00.0: loaded firmware version 27.455470.0 op_mode iwlmvm

the thing starts acting badly with this:

  iwlwifi 0000:3a:00.0: FW Error notification: type 0x00000000 cmd_id 0x04
  iwlwifi 0000:3a:00.0: FW Error notification: seq 0x0000 service 0x00000004
  iwlwifi 0000:3a:00.0: FW Error notification: timestamp 0x            5D84
  iwlwifi 0000:3a:00.0: Microcode SW error detected.  Restarting 0x2000000.
  iwlwifi 0000:3a:00.0: Start IWL Error Log Dump:
  iwlwifi 0000:3a:00.0: Status: 0x00000100, count: 6
  iwlwifi 0000:3a:00.0: Loaded firmware version: 27.455470.0
  iwlwifi 0000:3a:00.0: 0x00000038 | BAD_COMMAND
  iwlwifi 0000:3a:00.0: 0x00A002F0 | trm_hw_status0
  ...
  iwlwifi 0000:3a:00.0: 0x00000000 | isr status reg
  ieee80211 phy0: Hardware restart was requested
  iwlwifi 0000:3a:00.0: FW error in SYNC CMD MAC_CONTEXT_CMD
  CPU: 2 PID: 993 Comm: NetworkManager Not tainted 4.13.0-06466-g80cee03bf1d6 #4
  Hardware name: Dell Inc. XPS 13 9350/09JHRY, BIOS 1.4.17 05/10/2017
  Call Trace:
   dump_stack+0x4d/0x70
   iwl_trans_pcie_send_hcmd+0x4e7/0x530 [iwlwifi]
   ? wait_woken+0x80/0x80
   iwl_trans_send_cmd+0x5c/0xc0 [iwlwifi]
   iwl_mvm_send_cmd+0x32/0x90 [iwlmvm]
   iwl_mvm_send_cmd_pdu+0x58/0x80 [iwlmvm]
   iwl_mvm_mac_ctxt_send_cmd+0x2a/0x60 [iwlmvm]
   ? iwl_mvm_mac_ctxt_send_cmd+0x2a/0x60 [iwlmvm]
   iwl_mvm_mac_ctxt_cmd_sta+0x140/0x1e0 [iwlmvm]
   iwl_mvm_mac_ctx_send+0x2d/0x60 [iwlmvm]
   iwl_mvm_mac_ctxt_add+0x43/0xc0 [iwlmvm]
   iwl_mvm_mac_add_interface+0x139/0x2b0 [iwlmvm]
   ? iwl_led_brightness_set+0x1f/0x30 [iwlmvm]
   drv_add_interface+0x4a/0x120 [mac80211]
   ieee80211_do_open+0x33d/0x820 [mac80211]
   ieee80211_open+0x52/0x60 [mac80211]
   __dev_open+0xae/0x120
   __dev_change_flags+0x17b/0x1c0
   dev_change_flags+0x29/0x60
   do_setlink+0x2f7/0xe60
   ? __nla_put+0x20/0x30
   ? _raw_read_unlock_bh+0x20/0x30
   ? inet6_fill_ifla6_attrs+0x4be/0x4e0
   ? __kmalloc_node_track_caller+0x35/0x2b0
   ? nla_parse+0x35/0x100
   rtnl_newlink+0x5d2/0x8f0
   ? __netlink_sendskb+0x3b/0x60
   ? security_capset+0x40/0x80
   ? ns_capable_common+0x68/0x80
   ? ns_capable+0x13/0x20
   rtnetlink_rcv_msg+0x1f9/0x280
   ? rtnl_calcit.isra.26+0x110/0x110
   netlink_rcv_skb+0x8e/0x130
   rtnetlink_rcv+0x15/0x20
   netlink_unicast+0x18b/0x220
   netlink_sendmsg+0x2ad/0x3a0
   sock_sendmsg+0x38/0x50
   ___sys_sendmsg+0x269/0x2c0
   ? addrconf_sysctl_forward+0x114/0x280
   ? dev_forward_change+0x140/0x140
   ? sysctl_head_finish.part.22+0x32/0x40
   ? lockref_put_or_lock+0x5e/0x80
   ? dput.part.22+0x13e/0x1c0
   ? mntput+0x24/0x40
   __sys_sendmsg+0x54/0x90
   ? __sys_sendmsg+0x54/0x90
   SyS_sendmsg+0x12/0x20
   entry_SYSCALL_64_fastpath+0x13/0x94
  RIP: 0033:0x7ff1f9933134
  RSP: 002b:00007ffe7419b460 EFLAGS: 00000293 ORIG_RAX: 000000000000002e
  RAX: ffffffffffffffda RBX: 000055604b6d82b9 RCX: 00007ff1f9933134
  RDX: 0000000000000000 RSI: 00007ffe7419b4b0 RDI: 0000000000000007
  RBP: 00007ffe7419b940 R08: 0000000000000000 R09: 000055604d16b400
  R10: 00007ff1f7cf8b38 R11: 0000000000000293 R12: 0000000000000001
  R13: 0000000000000001 R14: 00007ffe7419b670 R15: 000055604b9515a0
  iwlwifi 0000:3a:00.0: Failed to send MAC context (action:1): -5

and it doesn't get any better from there. The next error seems to be

  Timeout waiting for hardware access (CSR_GP_CNTRL 0x08000008)
  ------------[ cut here ]------------
  WARNING: CPU: 3 PID: 1075 at
drivers/net/wireless/intel/iwlwifi/pcie/trans.c:1874
iwl_trans_pcie_grab_nic_access+0xdf/0xf0 [iwlwifi]

and it will continue with those microcode failure errors and various
other warnigns about how nothing is working.

And no, nothing works.  A lot of log output, no actual network access..

              Linus
