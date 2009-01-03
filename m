From: Yawhen Kasarzhewski <yevg@pisem.net>
Subject: tc ipt action bug
Date: Sat, 03 Jan 2009 22:29:28 +0200
Message-ID: <495FCAA8.1000005@pisem.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tut.by ([195.137.160.40]:36121 "EHLO speedy.tutby.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754353AbZACUpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jan 2009 15:45:09 -0500
Received: from [86.57.254.161] (account deza50293@tut.by HELO [192.168.1.7])
  by speedy.tutby.com (CommuniGate Pro SMTP 5.1.12)
  with ESMTPA id 122867108 for netdev@vger.kernel.org; Sat, 03 Jan 2009 22:29:49 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iproute is still using old iptables so failing to work with new xt_tables:

warp:~# tc filter add dev ppp0 parent ffff: protocol ip prio 10 u32 \
 >   match u32 0 0 flowid 1:1 \
 >   action ipt -j MARK --set-mark 1 \
 >   action mirred egress redirect dev ifb0
/lib/iptables/libipt_mark.so: cannot open shared object file: No such 
file or directory
failed to find target MARK
warp:~# find /lib -name "*mark.so"
/lib/ebtables/libebt_mark.so
/lib/xtables/libxt_connmark.so
/lib/xtables/libxt_mark.so
warp:~# iptables -V
iptables v1.4.1.1
warp:~# tc -V
tc utility, iproute2-ss080725
warp:~# uname -a
Linux warp 2.6.26 #2 Sun Jul 27 21:06:55 EEST 2008 i686 GNU/Linux

