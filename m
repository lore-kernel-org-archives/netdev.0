From: Karsten Keil <kkeil@suse.de>
Subject: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Wed, 9 Jan 2008 16:36:56 +0100
Message-ID: <20080109153656.GA16962@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:39924 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752535AbYAIPg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 10:36:58 -0500
Received: from Relay1.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id A19452FE02
	for <netdev@vger.kernel.org>; Wed,  9 Jan 2008 16:36:57 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I tried to run the 1.5.0 Beta2  TAHI Selftest on recent Linux kernel.
It fails in the Stateless Address Autoconfiguration section with
6 tests.
These tests are for Duplicate Address Detection (DAD).
They are detect for the Link Local Address a duplicate address on the
network. It seems that our current behavior is to log an message and
do not assign this address.

But the RFC 4862 says:

5.4.5.  When Duplicate Address Detection Fails

   A tentative address that is determined to be a duplicate as described
   above MUST NOT be assigned to an interface, and the node SHOULD log a
   system management error.

   If the address is a link-local address formed from an interface
   identifier based on the hardware address, which is supposed to be
   uniquely assigned (e.g., EUI-64 for an Ethernet interface), IP
   operation on the interface SHOULD be disabled.  By disabling IP
   operation, the node will then:

   -  not send any IP packets from the interface,

   -  silently drop any IP packets received on the interface, and

   -  not forward any IP packets to the interface (when acting as a
      router or processing a packet with a Routing header).

   In this case, the IP address duplication probably means duplicate
   hardware addresses are in use, and trying to recover from it by
   configuring another IP address will not result in a usable network.
   In fact, it probably makes things worse by creating problems that are
   harder to diagnose than just disabling network operation on the
   interface; the user will see a partially working network where some
   things work, and other things do not.

   On the other hand, if the duplicate link-local address is not formed
   from an interface identifier based on the hardware address, which is
   supposed to be uniquely assigned, IP operation on the interface MAY
   be continued.


So I think we should disable the interface now, if DAD fails on a
hardware based LLA.

-- 
Karsten Keil
SuSE Labs
