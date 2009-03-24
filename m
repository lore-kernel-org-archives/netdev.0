From: "Mr. Berkley Shands" <berkley@cs.wustl.edu>
Subject: 2.6.29 forcedeth hang W/O NAPI enabled
Date: Tue, 24 Mar 2009 10:28:25 -0500
Message-ID: <49C8FC19.5080201@cs.wustl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Mark A. Bober" <mark@cts.wustl.edu>,
	"Lloyd, Dave" <dlloyd@exegy.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postmark.cse.wustl.edu ([128.252.166.5]:34918 "EHLO
	mail.cse.wustl.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757329AbZCXP4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 11:56:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another new kernel, another interesting lock up. Centos 5.2, X86_84 on 
an opteron 8GB 4 cores (275 X 2).
If  CONFIG_FORCEDETH_NAPI is not enabled, then within 60 seconds of the 
console login prompt
appearing, the network becomes unresponsive. packets are seen to appear 
according to ifconfig eth0
and with ethtool -S eth0, but they go nowhere. NFS stops, ping stops, 
logins stop, ldap stops.
My network is class B, netmask 255.255.0.0, and the department router is 
directly connected
under this netmask. If I re-compile the forcedeth.ko with NAPI enabled, 
then reinstall it,
and depmod -aq then

service network stop; rmmod forcedeth; modprobe forcedeth; service 
network start

brings everything back online eventually. This was not an issue with 
2.6.28-8 or before.

Berkley



