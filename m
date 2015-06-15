From: Phil Sutter <phil@nwl.cc>
Subject: netstat and dual stack sockets
Date: Mon, 15 Jun 2015 22:54:21 +0200
Message-ID: <20150615205421.GA22616@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59900 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbbFOVAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 17:00:11 -0400
Received: from mail.nwl.cc (orbit [127.0.0.1])
	by mail.nwl.cc (Postfix) with ESMTP id 4036920094
	for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 22:54:22 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

A socket listening on any AF_INET6 address will receive IPv4 traffic as
well, as long as it does not set IPV6_V6ONLY (or sysctl
net.ipv6.bindv6only is set). Apache APR e.g. explicitly disables
IPV6_V6ONLY for listening sockets.

As I see it, a user has no way of detecting the listening socket in this
address family: it does not show in /proc/net/{tcp,udp} nor do
'netstat', 'ss' or 'lsof' print any additional information about those
sockets over pure IPv6 ones.

Is this correct? If so, are there any intentions to export the missing
information to userspace?

Phil
