From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] igb: Garbled output for "ethtool -m"
Date: Tue, 1 Mar 2016 01:32:33 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81EA72A7@ORSMSX101.amr.corp.intel.com>
References: <1455694465-1226-1-git-send-email-doron.shikmoni@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Doron Shikmoni <doron.shikmoni@gmail.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20128 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699AbcCABcg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 20:32:36 -0500
In-Reply-To: <1455694465-1226-1-git-send-email-doron.shikmoni@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [intel-wired-lan-bounces@lists.osuosl.org] on behalf of Doron Shikmoni [doron.shikmoni@gmail.com]
> Sent: Tuesday, February 16, 2016 11:34 PM
> To: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org
> Subject: [Intel-wired-lan] [PATCH] igb: Garbled output for "ethtool -m"
> 
> Hello,
> 
> Garbled output for "ethtool -m ethX", in igb-driven NICs with module /
> plugin EEPROM (i.e. SFP information). Each output data byte appears
> duplicated.
> 
> In igb_ethtool.c, igb_get_module_eeprom() is reading the EEPROM via i2c;
> the eeprom offset for each word that's read via igb_read_phy_reg_i2c()
> was passed in #words, whereas it needs to be a byte offset.
> This patches fixes the bug.
>
> Signed-off-by: Doron Shikmoni <doron.shikmoni@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Checkpatch complains that you pushed the line over 80 characters:
------------------------
u1463:[0]/usr/src/kernels/next-queue> git format-patch $item -1 --stdout|./scripts/checkpatch.pl -
WARNING: line over 80 characters
#29: FILE: drivers/net/ethernet/intel/igb/igb_ethtool.c:3010:
+               status = igb_read_phy_reg_i2c(hw, (first_word + i) * 2, &dataword[i]);

total: 0 errors, 1 warnings, 0 checks, 8 lines checked

Your patch has style problems, please review.

NOTE: If any of the errors are false positives, please report
      them to the maintainer, see CHECKPATCH in MAINTAINERS.
u1463:[0]/usr/src/kernels/next-queue> 
------------------------

But functionally seems good.  I'll let Jeff choose whether to be a stickler for the warning or not, so...

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
