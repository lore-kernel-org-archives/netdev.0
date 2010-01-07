From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 0/3] e1000e,igb,ixgbe: add registers etc. printout code just
 before resetting adapters
Date: Thu, 07 Jan 2010 19:47:01 +0900
Message-ID: <4B45BBA5.8010407@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
To: netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:39327 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370Ab0AGKrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 05:47:46 -0500
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o07Alig1030900
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Thu, 7 Jan 2010 19:47:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 745B745DE4F
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 19:47:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4615F45DE51
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 19:47:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7484E1DB8038
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 19:47:43 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B69EF1DB8063
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 19:47:42 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patchset adds registers etc. printout code just before resetting adapters
to e1000e, igb, ixgbe modules. The registers, tx/rx rings status, descriptors,
and buffer info will be helpful for detecting the root cause of adapters reset.

This patchset is based on the following Jesse's debug patch of e1000e module.
 http://marc.info/?l=linux-netdev&m=121446492912285&w=2
I think that code is very useful, and should be comitted to upstream.

The main difference between Jesse's patch and mine is as follows:
  - the function which invokes xxx_dump function. (xxx_clean_tx_irq -> xxx_reset_task)
  - add the "dump_flag" module option to select category of printout

The default output is netdevice status (transstart, last_rx), registers,
and tx/rx rings' simple information. TX/RX descriptors information and
buffer_info  can be output by changing the dump_flag module option, but,
of course, the amount of output becomes quite large.

  *[PATCH 1/3] e1000e: add registers etc. printout code just before resetting adapters
  *[PATCH 2/3] igb: add registers etc. printout code just before resetting adapters
  *[PATCH 3/3] ixgbe: add registers etc. printout code just before resetting adapters

Best regards,
Taku Izumi <izumi.taku@jp.fujitsu.com>

