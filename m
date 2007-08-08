From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 08 Aug 2007 09:18:31 -0700
Message-ID: <aday7gmov8o.fsf@cisco.com>
References: <200708080045.l780jE9E004667@neteffect.com>
	<20070808133850.GE14419@one.firstfloor.org>
	<200708081548.25399.mb@bu3sch.de> <200708081555.03588.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Jeff Garzik <jeff@garzik.org>,
	ggrundstrom@neteffect.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:53656 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765152AbXHHQSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 12:18:38 -0400
In-Reply-To: <200708081555.03588.mb@bu3sch.de> (Michael Buesch's message of "Wed, 8 Aug 2007 15:55:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > But there are indeed a few cases that look wrong.

yes...

 > arch/x86_64/kernel/pci-calgary.c:       writel(cpu_to_be32(val), target);

eg this almost certainly wants to be

	writel(swab32(val), target);

or something equivalent like

	__raw_writel(cpu_to_be32(val), target);
	/* plus some suffficent memory ordering */

 - R.
