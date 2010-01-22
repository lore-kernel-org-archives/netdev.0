From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout code
 just before resetting adapters
Date: Fri, 22 Jan 2010 14:45:24 +0900
Message-ID: <4B593B74.2020601@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	chavey@google.com
To: netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:51324 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab0AVFpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 00:45:46 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0M5jibu022076
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 22 Jan 2010 14:45:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EE5C45DE51
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:45:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D4F7145DE4D
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:45:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BBAB31DB8045
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:45:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 59C951DB8041
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:45:43 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

This patchset is the update version of "register etc. printout code" patch. (sorry
for late reply)
The old one is http://marc.info/?l=linux-netdev&m=126286127208276&w=2

v1 -> v2:
 - replaced hexdump() with print_hex_dump()
 - changed the register printout inplementation (for-switch-case -> data-driven-table)

However the default value of "dump_flag" is not changed (still 1).
The reason I didn't change is
 - I think HW index (TDH,TDT..) and SW index (NTC,NTU) are at least necessary
 - the amount of default output is not so large (see bellow)
 - the adapter resetting problem doesn't happen frequently


The default output sample (NOT the actual hangup case) is as follows:

Jan 22 14:17:14 fedora11 kernel: igb 0000:03:00.0: Net device Info
Jan 22 14:17:14 fedora11 kernel: Device Name     state            trans_start
last_rx
Jan 22 14:17:14 fedora11 kernel: eth1            0000000000000003 00000000FFFB922A
0000000000000000
Jan 22 14:17:14 fedora11 kernel: igb 0000:03:00.0: Register Dump
Jan 22 14:17:14 fedora11 kernel: Register Name   [value ]
Jan 22 14:17:14 fedora11 kernel: CTRL            18c00241
Jan 22 14:17:14 fedora11 kernel: STATUS          00080783
Jan 22 14:17:14 fedora11 kernel: CTRL_EXT        10180c00
Jan 22 14:17:14 fedora11 kernel: ICR             00000081
Jan 22 14:17:14 fedora11 kernel: RCTL            0400803a
Jan 22 14:17:14 fedora11 kernel: RDLEN[0-3]      00001000 00001000 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: RDH[0-3]        000000bc 00000000 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: RDT[0-3]        000000ba 000000fe 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: RXDCTL[0-3]     02010810 02010810 00010000 00010000
Jan 22 14:17:14 fedora11 kernel: RDBAL[0-3]      35e48000 35f68000 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: RDBAH[0-3]      00000000 00000000 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: TCTL            a503f0fa
Jan 22 14:17:14 fedora11 kernel: TDBAL[0-3]      35e4c000 35ef1000 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: TDBAH[0-3]      00000000 00000000 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: TDLEN[0-3]      00001000 00001000 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: TDH[0-3]        00000000 0000001e 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: TDT[0-3]        00000000 0000001e 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: TXDCTL[0-3]     02000108 02000108 00000000 00000000
Jan 22 14:17:14 fedora11 kernel: TDFH            40020272
Jan 22 14:17:14 fedora11 kernel: TDFT            00000270
Jan 22 14:17:14 fedora11 kernel: TDFHS           00000272
Jan 22 14:17:14 fedora11 kernel: TDFPC           00000000
Jan 22 14:17:14 fedora11 kernel: igb 0000:03:00.0: TX Rings Summary
Jan 22 14:17:14 fedora11 kernel: Queue [NTU] [NTC] [bi(ntc)->dma  ] leng ntw timestamp
Jan 22 14:17:14 fedora11 kernel:     0     0     0 0000000000000000 0000   0
0000000000000000
Jan 22 14:17:14 fedora11 kernel:     1    1E    1E 0000000000000000 0000   0
0000000000000000
Jan 22 14:17:14 fedora11 kernel: igb 0000:03:00.0: RX Rings Summary
Jan 22 14:17:14 fedora11 kernel: Queue [NTU] [NTC]
Jan 22 14:17:14 fedora11 kernel:     0    BB    BC
Jan 22 14:17:14 fedora11 kernel:     1    FF     0


Best regards,
Taku Izumi

