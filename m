From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: pppoe relay and MAC address filtering
Date: Thu, 16 Apr 2015 11:34:34 +0000
Message-ID: <1429184073.12901.34.camel@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.transmode.se ([31.15.61.139]:61617 "EHLO smtp.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753747AbbDPLoD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 07:44:03 -0400
Received: from exch2.transmode.se (exch2.transmode.se [192.168.203.24])
	by smtp.transmode.se (Postfix) with ESMTP id C6F601186FE0
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 13:34:34 +0200 (CEST)
Content-Language: en-US
Content-ID: <4243157921D27148AA88C455C6D7357B@transmode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have create pppoe session over a pppoe relay socket:
A B and C are Linux nodes, B impl. a relay socket so
that A and B can create a pppoe session:

A ifA---------ifB0 B ifB1----------ifC C

Now I noticed that if ifB0 is in promisc mode it picks up other pppoe pkgs which
are meant for some other pppoe session to another node(D) and relays this
pkg to node C!

To me this looks like the pppoe relay socket does not check if the DST MAC on
pppoe pkgs received over ifB0 matches ifB0 MAC address?
Instead the relay socket happily relays any pppoe pkg as long as the session id matches.

This feels like a bug to me, comments?

  Jocke