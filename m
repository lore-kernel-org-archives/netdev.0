From: Tero Marttila <tero.marttila@aalto.fi>
Subject: Behaviour of sysctl net.ipv6.conf.all.* parameters
Date: Wed, 24 Jun 2015 17:17:42 +0300
Message-ID: <558ABC06.2060201@aalto.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-01.aalto.fi ([130.233.228.120]:54680 "EHLO
	smtp-out-01.aalto.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbbFXOXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 10:23:36 -0400
Received: from smtp-out-01.aalto.fi (localhost.localdomain [127.0.0.1])
	by localhost (Email Security Appliance) with SMTP id F2D371152DB_58ABC06B
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 14:17:42 +0000 (GMT)
Received: from EXHUB02.org.aalto.fi (exhub02.org.aalto.fi [130.233.222.119])
	by smtp-out-01.aalto.fi (Sophos Email Appliance) with ESMTP id C93101152C1_58ABC06F
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 14:17:42 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was exploring the behavior of various net.ipv6.conf.all parameters
such as use_tempaddr on Linux 3.16, but the behavior doesn't seem to
make sense.

The following settings do *not* result in privacy addresses on eth0:

	net.ipv6.conf.all.use_tempaddr=2
	net.ipv6.conf.eth0.use_tempaddr=0

But the following settings do:

	net.ipv6.conf.all.use_tempaddr=0
	net.ipv6.conf.eth0.use_tempaddr=2

This doesn't make sense per any of the AND/OR/MAX semantics as used for
e.g. net.ipv4.conf.all.

Looking at the net/ipv6/addrconf.c implementation, I can figure out
where net.ipv6.conf.default is implemented, and some handling for
specific devconf_all parameters (forwarding, disable_ipv6, proxy_ndp),
but I am unable to find any link between struct
netns_ipv6.devconf_all.use_tempaddr and struct inet6_dev.cnf.use_tempaddr.

Does anyone have any pointers for where this linking logic would be
implemented, or are the majority of net.ipv6.conf.all.* sysctl
parameters actually complete no-ops?

 -- Tero Marttila
