From: "Andy Cress" <andy.cress@us.kontron.com>
Subject: [PATCH 0/4] pch_gbe: avoiding transmit timeouts (rev 2)
Date: Mon, 16 Jul 2012 13:02:37 -0700
Message-ID: <40680C535D6FE6498883F1640FACD44D011432D2@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.kontron.com ([209.118.138.70]:59264 "EHLO
	mail.us.kontron.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919Ab2GPUCk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 16:02:40 -0400
Received: from ka-exchange-1.kontronamerica.local ([10.100.2.39]) by mail.us.kontron.com with ESMTP id HhySzhVWY4bRQdep for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 13:02:40 -0700 (PDT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When the interface is stressed with 6 VLANs, some transmit timeout stats
were 
observed, which is a potential precursor to the more severe netdev
watchdog 
timeout oops.  Also we saw more than the expected number of
transmit restarts, which impacted performance.   The following patches
were applied and resolved the symptom of the transmit timeout stats, and

reduced the number of transmit restarts.  

This patch set includes the following patches:
0001-pch_gbe-Fix-the-checksum-fill-to-the-error-location.patch
0002-pch_gbe-fix-transmit-watchdog-timeout.patch
0003-pch_gbe-add-extra-clean-tx.patch  (includes bumping the version to
1.01) 
0004-pch_gbe-vlan-skb-len-fix.patch

This rev2 has the following changes:
0001: tested w skb_checksum_start_offset, but cannot use it here, added
comment
0004: delete transmit length error check as unnecessary

The resulting pch_gbe 1.01 driver has been tested on Kontron Tunnel
Creek 
EG20T modules and Intel Crown Bay EG20T modules, so I believe that these
are 
appropriate for consideration in the upstream pch_gbe driver.


Please review and comment.

Thanks,
Andy
