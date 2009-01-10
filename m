From: Roland Dreier <rdreier@cisco.com>
Subject: Some NIPQUAD_FMT -> %pI4 conversions are broken
Date: Fri, 09 Jan 2009 19:47:51 -0800
Message-ID: <adaprivom8o.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Harvey Harrison <harvey.harrison@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:29996 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbZAJDrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 22:47:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just noticed (by getting a messed up print in my kernel log) that most
of the changes to drivers/infiniband/hw/nes in commit 63779436
("drivers: replace NIPQUAD()") were wrong: the idea was to change printk
statements like

	printk("..." NIPQUAD_FMT "...", NIPQUAD(foo));

but most of the changes in nes were to code like

	printk("..." NIPQUAD_FMT "...", HIPQUAD(foo));

ie *H* IPQUAD not *N* IPQUAD, indicating the foo is in host endian
order, and hence the new code

	printk("...%pI4...", &foo);

prints the IP in reverse order now.

I don't see a good way to fix this without introducing a temporary
variable to hold a swapped IP address... but is there a better way?

 - R.
