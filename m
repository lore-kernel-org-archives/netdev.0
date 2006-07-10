From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: active-backup/bonding with drivers not supporting set_mac_address()
Date: Mon, 10 Jul 2006 16:43:36 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0607101618390.26558@zuben>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:62172 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP id S965008AbWGJNni
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 09:43:38 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looking on the linux bonding driver, it seems to unconditionally (*)
assume that the enslaved device supports the set_mac_address call.

>From reading the doc (Documentation/networking/bonding.txt) i understand that
it is **not** a must prerequisite for the active-backup mode, this is since
there is at most one active slave at each point of time and as the doc states:

	when a failover occurs in active-backup mode, bonding will issue
	one or more gratuitous ARPs on the newly active slave.

I'd like to get feedback from people here if you think it makes sense
to change the bonding driver to actually allow for active-backup/bonding
with network device drivers which does not support set_mac_address.

thanks,

Or Gerlitz.

(*) in the sense that it checks for each enslaved device and reports
an error if dev->set_mac_address is not supported and later use
dev_set_mac_address elsewhere in the code.

