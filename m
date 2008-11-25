From: Hermann Lauer <Hermann.Lauer@iwr.uni-heidelberg.de>
Subject: sumgem problems with initializiation order at a 1000SX SERDES card
Date: Tue, 25 Nov 2008 11:30:29 +0100
Message-ID: <20081125103029.GD12605@lemon.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.uni-heidelberg.de ([129.206.210.211]:52196 "EHLO
	relay2.uni-heidelberg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbYKYOFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 09:05:55 -0500
Received: from mail.iwr.uni-heidelberg.de (mail.iwr.uni-heidelberg.de [129.206.104.30])
	by relay2.uni-heidelberg.de (8.13.8/8.13.8) with ESMTP id mAPAUUbl027623
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 11:30:30 +0100
Received: from lemon.iwr.uni-heidelberg.de (lemon.iwr.uni-heidelberg.de [129.206.104.80])
	by mail.iwr.uni-heidelberg.de (8.12.11/8.12.11) with ESMTP id mAPAUTjI004674
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 11:30:29 +0100 (MET)
Received: (from hlauer@localhost)
	by lemon.iwr.uni-heidelberg.de (8.13.6/8.12.11) id mAPAUTUi012679
	for netdev@vger.kernel.org; Tue, 25 Nov 2008 11:30:29 +0100 (MET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
the current sungem driver sets up the phy layer when insmoding the
driver, and later resets the gem chip in gem_reinit_chip(), called
from gem_do_start() which is called when a "ifconfig up" is done.

Unfortunately with the sun PCI FIBER 1000SX-card (which uses a SERDES
connected to the gem PCS part) this resets the
gem included PCS part too, which then cancels the previously established 
link (see debug output below).

Any idea how that could be solved ?

Thanks,
  Hermann

PS: There is only one "writeb" call in the code to reset the PCS, but the 
value is read with a readl. Typo ?

----------------------------------------------------------------
Some PCS registers before and after gem_reset(gp) is executed in 
gem_reinit_chip().

eth2: PCS_MIISTAT:a 12c, pcs_lpa=4120, PCS_MIIADV: 1e0
eth2: PCS_MIISTAT:b 108, pcs_lpa=0, PCS_MIIADV: e0

Note that e0 is the default PCS_MIIADV register value according to the docs.
  
-- 
Netzwerkadministration/Zentrale Dienste, Interdiziplinaeres 
Zentrum fuer wissenschaftliches Rechnen der Universitaet Heidelberg
IWR; INF 368; 69120 Heidelberg; Tel: (06221)54-8236 Fax: -5224
Email: Hermann.Lauer@iwr.uni-heidelberg.de
