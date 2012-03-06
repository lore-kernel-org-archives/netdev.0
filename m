From: Arnd Hannemann <arnd@arndnet.de>
Subject: 2.6.34 -> 3.0.23 regression?
Date: Tue, 06 Mar 2012 22:16:19 +0100
Message-ID: <4F567EA3.5000102@arndnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.unitix.de ([176.9.2.175]:41818 "EHLO mail2.unitix.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755634Ab2CFVYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 16:24:25 -0500
Received: from [192.168.1.64] (77-216.eduroam.rwth-aachen.de [134.61.77.216])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.unitix.de (Postfix) with ESMTPSA id 78CAF4EF1
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 22:16:19 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I upgraded a router box from kernel 2.6.34 to 3.0.23.
After the upgrade my proxy redirect was not working anymore
until I manually put the LAN interface (br0) in promisc mode.

Is it expected behavior that I need to set the interface into PROMISC
mode in order to get DNAT in PREROUTING to work?
With kernel 2.6.34 this was not needed...

Details:
192.168.1.1 is a router box and default gateway for clients
  connected to 192.168.1.0/24 via br0,
  connected to internet via wlan0,
192.168.1.2 is a proxy server running squid on port 3128

Iptables rules -t nat (simplified)
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DNAT       tcp  -- !192.168.1.2          0.0.0.0/0           tcp dpt:80 to:192.168.1.2:3128

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
SNAT       tcp  --  192.168.1.0/24       0.0.0.0/0           tcp dpt:3128 to:192.168.1.1


Best regards
Arnd
