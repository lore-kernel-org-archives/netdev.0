From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: ipv4 dead route delete notification on netdev down
Date: Sat, 20 Sep 2014 21:02:28 -0700
Message-ID: <541E4DD4.1050609@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	nicolas.dichtel@6wind.com, Thomas Graf <tgraf@suug.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48976 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbaIUECe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 00:02:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The kernel does not send notification for deleted dead ipv4 routes on 
netdev down.
This has been brought up before and patches for the fix have been rejected.
The reason for rejection is that the routing daemons are expected to 
purge their
routing tables on netdev down notifications.

http://www.spinics.net/lists/netdev/msg215161.html
http://lists.openwall.net/netdev/2013/10/17/55

This issue keeps coming back. We run into this too. Wanted to send this 
email out to see if opinions have changed.

There are multiple problems:
1) inconsistency in kernel notification behavior between ipv4 and ipv6 
for dead routes
2) Its not just the routing daemons, its also the userspace netlink 
caches like libnl. In abcense of a direct notification,
these will have to purge the routes on link down too.

Thanks,
Roopa
