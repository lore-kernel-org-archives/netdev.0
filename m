From: Sergey Popov <popov_sergey@ukr.net>
Subject: some bug in iproute2
Date: Thu, 6 Aug 2009 11:50:35 +0300
Message-ID: <20090806115035.42a22dfc@azure>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plaza.ukrnafta.kharkov.ua ([193.189.96.114]:39449 "EHLO
	plaza.ukrnafta.kharkov.ua" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbZHFI54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 04:57:56 -0400
Received: from azure (208-65-112-92.pool.ukrtel.net [92.112.65.208])
	(Authenticated sender: azure@azure.org.ua)
	by plaza.ukrnafta.kharkov.ua (Postfix) with ESMTPA id C2F9022005A
	for <netdev@vger.kernel.org>; Thu,  6 Aug 2009 11:50:38 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

# tc f add dev eth0 parent 1: proto ip prio 2 u32 match u32 0 0 action ipt -j MARK --set-mark 1
/usr/lib64/iptables/libipt_mark.so: cannot open shared object file: No such file or directory
failed to find target MARK

bad action parsing
parse_action: bad value (5:ipt)!
Illegal "action"


But mark target is compiled in kernel (not a module)

# iptables -t mangle -A PREROUTING -i eth1 -j MARK --set-mark 1
# iptables -t mangle -L PREROUTING
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination         
MARK       all  --  anywhere             anywhere            MARK xset
0x1/0xffffffff 

This shouldn't be.
