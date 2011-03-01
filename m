From: Joe Buehler <aspam@cox.net>
Subject: source route ignored in favor of local interface
Date: Tue, 1 Mar 2011 14:57:52 +0000 (UTC)
Message-ID: <loom.20110301T154947-689@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:42956 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756534Ab1CAO6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 09:58:06 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PuR1Y-0005lt-6B
	for netdev@vger.kernel.org; Tue, 01 Mar 2011 15:58:04 +0100
Received: from netrokpix001.spirentcom.com ([96.241.21.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 15:58:04 +0100
Received: from aspam by netrokpix001.spirentcom.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 15:58:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a LINUX box talking on many different networks at the same time.  Since
IP addresses on the networks can overlap (they are completely different
networks) we use source routing and NAT to get packets going in and out of the
right interfaces.

Everything works great, with one exception.  If I try to talk to a remote host
that happens to have the same IP address as one of my interfaces, the kernel
routes the packet to the local interface.

It looks to me as though the problem is that the source routes are lower
priority than the local interfaces.  As soon as the kernel sees a destination
address that matches a local interface it routes to the local interface and pays
no attention to the source route.

I consider this a bug.  Is there any way to change this behavior?

The kernel involved is 2.6.27.7, with patches from Cavium for support of their
hardware.

Joe Buehler


