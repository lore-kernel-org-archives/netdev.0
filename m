From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: fe80::/64 route missing on GRE tunnels
Date: Tue, 11 Feb 2014 22:55:11 +0100
Message-ID: <20140211215510.GA6994@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: itk-intern@samfundet.no
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:47990 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680AbaBKVzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 16:55:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It seems that recent kernels no longer automatically add the link-local route
to GRE tunnels. 3.10.27 does it right:

  root@morgental:~# ip tunnel add foo mode gre remote 1.2.3.4 ttl 64
  root@morgental:~# ip link set foo up mtu 1468
  root@morgental:~# ip -6 route show dev foo
  fe80::/64  proto kernel  metric 256 

but on 3.13.1, no such route shows up. I can add it manually, though.

This broke our in-house IPv6 tunnel broker (which essentially uses link-local
addresses over GRE tunnels to bring up BGP sessions). Do you think you could
have a look?

/* Steinar */
-- 
Homepage: http://www.sesse.net/
