From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: kernel panic TPROXY , vanilla 4.7.1
Date: Wed, 17 Aug 2016 17:31:20 +0300
Message-ID: <627722c51d9ce454dfaf1a79519ceb59@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:60144 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255AbcHQOtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 10:49:09 -0400
Received: from localhost (localhost [127.0.0.1])
	by nuclearcat.com (Postfix) with ESMTP id 73E3F67C0088
	for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 14:31:22 +0000 (UTC)
Received: from nuclearcat.com ([127.0.0.1])
	by localhost (nuclearcat.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZNY5XfOewPrm for <netdev@vger.kernel.org>;
	Wed, 17 Aug 2016 14:31:20 +0000 (UTC)
Received: from germany.nuclearcat.com (localhost [127.0.0.1])
	(Authenticated sender: nuclearcat@nuclearcat.com)
	by nuclearcat.com (Postfix) with ESMTPA id B783D67C0087
	for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 14:31:20 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Tried to run squid on latest kernel, and hit a panic
Sometimes it just shows warning in dmesg (but doesnt work properly)
[   75.701666] IPv4: Attempt to release TCP socket in state 10 
ffff88102d430780
[   83.866974] squid (2700) used greatest stack depth: 12912 bytes left
[   87.506644] IPv4: Attempt to release TCP socket in state 10 
ffff880078a48780
[  114.704295] IPv4: Attempt to release TCP socket in state 10 
ffff881029f8ad00

I cannot catch yet oops/panic message, netconsole not working.

After triggering warning message 3 times, i am unable to run squid 
anymore (without reboot), and in netstat it doesnt show port running.

firewall is:
*mangle
-A PREROUTING -p tcp -m socket -j DIVERT
-A PREROUTING -p tcp -m tcp --dport 80 -i eno1 -j TPROXY --on-port 3129 
--on-ip 0.0.0.0 --tproxy-mark 0x1/0x1
-A DIVERT -j MARK --set-xmark 0x1/0xffffffff
-A DIVERT -j ACCEPT

routing
ip rule add fwmark 1 lookup 100
ip route add local default dev eno1 table 100


squid config is default with tproxy option
http_port 3129 tproxy
