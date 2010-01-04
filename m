From: Simon Horman <horms@verge.net.au>
Subject: regression in socket match caused by "net: Fix RPF to work with
 policy routing"
Date: Mon, 4 Jan 2010 21:04:23 +1100
Message-ID: <20100104100417.GA7699@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDEV list <netdev@vger.kernel.org>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45656 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753141Ab0ADKEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 05:04:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

the patch "net: Fix RPF to work with policy routing",
which was added between 2.6.32-rc5 and rc6 seems to
cause a regression when using the socket match.

In particular I'm using IP_TRANSPARENT as detailed
in Documentation/networking/tproxy.txt with the following
rules:

iptables -t mangle -N DIVERT
iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT
ip rule add fwmark 1 lookup 100
ip route add local 0.0.0.0/0 dev lo table 100

