From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 0/2] netdev: Add tracepoint to network/driver interface
Date: Fri, 09 Apr 2010 16:37:53 +0900
Message-ID: <4BBED951.8040406@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com,
	davem@davemloft.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:44385 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754142Ab0DIHhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 03:37:35 -0400
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o397bXnJ024017
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Fri, 9 Apr 2010 16:37:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 98E5D45DE6F
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:37:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7498D45DE4D
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:37:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C70A1DB8037
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:37:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B1701DB803E
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 16:37:30 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add tracepoints to network/driver interface.

These tracepoints are helpful to investigate whether a packet passes or not.
For example, when Heart Beat is disconnected, that information is helpful
to investigate the cause is whether driver/device side or not.

An output is below.

   sshd-2443  [001] 68238.415621: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114
<idle>-0     [001] 68238.417058: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=52
<idle>-0     [001] 68238.704363: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=100
   sshd-2443  [001] 68238.705459: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114
<idle>-0     [001] 68238.706891: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=52
<idle>-0     [001] 68238.878736: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=100
   sshd-2443  [001] 68238.880361: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114

As other use case I have, we can get throughput per interface with some sort of
perf scripts. I plan to create it.

Thanks
Koki Sanagi

