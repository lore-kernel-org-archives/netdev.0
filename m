From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fix stack out-of-bounds read due to wrong
 size to t4_record_mbox()
Date: Mon, 28 Aug 2017 15:24:46 -0700 (PDT)
Message-ID: <20170828.152446.1981724368219029883.davem@davemloft.net>
References: <04759fe12e6a8eb8e36e46060b907f02c269a826.1503692361.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ganeshgr@chelsio.com, netdev@vger.kernel.org,
        hariprasad@chelsio.com, leedom@chelsio.com, svemuri@redhat.com
To: sbrivio@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751213AbdH1WYr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:24:47 -0400
In-Reply-To: <04759fe12e6a8eb8e36e46060b907f02c269a826.1503692361.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefano Brivio <sbrivio@redhat.com>
Date: Fri, 25 Aug 2017 22:48:48 +0200

> Passing commands for logging to t4_record_mbox() with size
> MBOX_LEN, when the actual command size is actually smaller,
> causes out-of-bounds stack accesses in t4_record_mbox() while
> copying command words here:
> 
> 	for (i = 0; i < size / 8; i++)
> 		entry->cmd[i] = be64_to_cpu(cmd[i]);
> 
> Up to 48 bytes from the stack are then leaked to debugfs.
> 
> This happens whenever we send (and log) commands described by
> structs fw_sched_cmd (32 bytes leaked), fw_vi_rxmode_cmd (48),
> fw_hello_cmd (48), fw_bye_cmd (48), fw_initialize_cmd (48),
> fw_reset_cmd (48), fw_pfvf_cmd (32), fw_eq_eth_cmd (16),
> fw_eq_ctrl_cmd (32), fw_eq_ofld_cmd (32), fw_acl_mac_cmd(16),
> fw_rss_glb_config_cmd(32), fw_rss_vi_config_cmd(32),
> fw_devlog_cmd(32), fw_vi_enable_cmd(48), fw_port_cmd(32),
> fw_sched_cmd(32), fw_devlog_cmd(32).
> 
> The cxgb4vf driver got this right instead.
> 
> When we call t4_record_mbox() to log a command reply, a MBOX_LEN
> size can be used though, as get_mbox_rpl() will fill cmd_rpl up
> completely.
> 
> Fixes: 7f080c3f2ff0 ("cxgb4: Add support to enable logging of firmware mailbox commands")
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
> ---
> I guess this should be queued up for -stable, back to 4.7.

Applied and queued up for -stable, thanks.
