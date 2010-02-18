From: reinette chatre <reinette.chatre@intel.com>
Subject: Re: [patch] iwlwifi: testing the wrong variable
Date: Thu, 18 Feb 2010 10:04:42 -0800
Message-ID: <1266516282.2551.2604.camel@rchatre-DESK>
References: <20100218094529.GA1298@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Zhu, Yi" <yi.zhu@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	"Kolekar, Abhijeet" <abhijeet.kolekar@intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46562 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751932Ab0BRSEn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 13:04:43 -0500
In-Reply-To: <20100218094529.GA1298@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-18 at 01:45 -0800, Dan Carpenter wrote:
> The first one fixes a smatch false positive and the second one fixes
> a potential bug.
> 
> drivers/net/wireless/iwlwifi/iwl-5000.c +786 iwl5000_txq_update_byte_cnt_tbl(37) error: buffer overflow 
> '(scd_bc_tbl+txq_id)->tfd_offset' 320 <= 512
> drivers/net/wireless/iwlwifi/iwl-5000.c +808 iwl5000_txq_inval_byte_cnt_tbl(19) error: buffer overflow 
> '(scd_bc_tbl+txq_id)->tfd_offset' 320 <= 512
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> Cc: stable@kernel.org
> ---

This has already been fixed by patch below (taken from
wireless-next-2.6). John and Greg, could you please pick this one up for
2.6.33 and stable instead?

commit 8ce1ef4a914aef8b9b90a2a2c670494168a2cca9
Author: Wey-Yi Guy <wey-yi.w.guy@intel.com>
Date:   Fri Jan 8 10:04:44 2010 -0800

    iwlwifi: fix bug in tx byte count table
    
    When setting invalid byte count in txq byte count table, read
pointer
    should be used instead of write pointer.
    
    Reported-by: Guo, Chaohong <chaohong.guo@intel.com>
    Signed-off-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
    Signed-off-by: Zhu Yi <yi.zhu@intel.com>
    Signed-off-by: Reinette Chatre <reinette.chatre@intel.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

Reinette


