From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: 2.6.35, netfilter/iptables not working with 32bit userspace +
	64bit kernel?
Date: Fri, 13 Aug 2010 13:47:06 +0300
Message-ID: <20100813134706.509472n222yo71d6@hayate.sektori.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tulikuusama.dnainternet.net ([83.102.40.132]:50592 "EHLO
	tulikuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934140Ab0HMKxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 06:53:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by tulikuusama.dnainternet.net (Postfix) with ESMTP id 77DB52C816
	for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 13:47:07 +0300 (EEST)
Received: from tulikuusama.dnainternet.net ([83.102.40.132])
	by localhost (tulikuusama.dnainternet.net [127.0.0.1]) (amavisd-new, port 10041)
	with ESMTP id exvXaD0tbKIm for <netdev@vger.kernel.org>;
	Fri, 13 Aug 2010 13:47:07 +0300 (EEST)
Received: from omenapuu.dnainternet.net (omenapuu.dnainternet.net [83.102.40.212])
	by tulikuusama.dnainternet.net (Postfix) with ESMTP id 58EA62C799
	for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 13:47:07 +0300 (EEST)
Received: from localhost (dyn2-85-23-163-154.psoas.suomi.net [85.23.163.154])
	by omenapuu.dnainternet.net (Postfix) with ESMTP id 273A82BAD5
	for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 13:47:06 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I have server/firewall running Debian lenny with 32bit userspace and  
64bit kernel. After upgrading from 2.6.34 to 2.6.35, I couldn't get  
any new chains work. Simply doing (with 32bit iptables)

   iptables -N new_chain
   iptables -A OUTPUT -j new_chain
   iptables -A OUTPUT -j ACCEPT

cause output to freeze. "iptables -L -vn" shows:

Chain OUTPUT (policy ACCEPT 3397 packets, 637K bytes)
  pkts bytes target     prot opt in     out     source         destination
     3   252 new_chain  all  --  *      *       0.0.0.0/0      0.0.0.0/0
     0     0 ACCEPT     all  --  *      *       0.0.0.0/0      0.0.0.0/0

Ping shows "ping: sendmsg: Operation not permitted".

With recompiled 64bit iptables, example above works fine.

-Jussi

