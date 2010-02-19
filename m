From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch] iwlwifi: testing the wrong variable
Date: Fri, 19 Feb 2010 15:30:39 -0500
Message-ID: <20100219203039.GN4950@tuxdriver.com>
References: <20100218094529.GA1298@bicker> <1266516282.2551.2604.camel@rchatre-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <error27@gmail.com>, "Zhu, Yi" <yi.zhu@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	"Kolekar, Abhijeet" <abhijeet.kolekar@intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: reinette chatre <reinette.chatre@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57533 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775Ab0BSUpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 15:45:41 -0500
Content-Disposition: inline
In-Reply-To: <1266516282.2551.2604.camel@rchatre-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2010 at 10:04:42AM -0800, reinette chatre wrote:
> On Thu, 2010-02-18 at 01:45 -0800, Dan Carpenter wrote:
> > The first one fixes a smatch false positive and the second one fixes
> > a potential bug.
> > 
> > drivers/net/wireless/iwlwifi/iwl-5000.c +786 iwl5000_txq_update_byte_cnt_tbl(37) error: buffer overflow 
> > '(scd_bc_tbl+txq_id)->tfd_offset' 320 <= 512
> > drivers/net/wireless/iwlwifi/iwl-5000.c +808 iwl5000_txq_inval_byte_cnt_tbl(19) error: buffer overflow 
> > '(scd_bc_tbl+txq_id)->tfd_offset' 320 <= 512
> > 
> > Signed-off-by: Dan Carpenter <error27@gmail.com>
> > Cc: stable@kernel.org
> > ---
> 
> This has already been fixed by patch below (taken from
> wireless-next-2.6). John and Greg, could you please pick this one up for
> 2.6.33 and stable instead?
> 
> commit 8ce1ef4a914aef8b9b90a2a2c670494168a2cca9
> Author: Wey-Yi Guy <wey-yi.w.guy@intel.com>
> Date:   Fri Jan 8 10:04:44 2010 -0800
> 
>     iwlwifi: fix bug in tx byte count table
>     
>     When setting invalid byte count in txq byte count table, read
> pointer
>     should be used instead of write pointer.
>     
>     Reported-by: Guo, Chaohong <chaohong.guo@intel.com>
>     Signed-off-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
>     Signed-off-by: Zhu Yi <yi.zhu@intel.com>
>     Signed-off-by: Reinette Chatre <reinette.chatre@intel.com>
>     Signed-off-by: John W. Linville <linville@tuxdriver.com>

So for the record, that patch is basically identical to Dan's patch
but with some whitespace fixups in some nearby lines as well.

How important is this patch?  Is there an actual bug report?  Is it
a regression?

It is very late in the 2.6.33 cycle and it isn't obvious to me that
this is worth pushing for 2.6.33 at this point...?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
