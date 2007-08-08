From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 08 Aug 2007 09:46:16 -0700
Message-ID: <adair7qotyf.fsf@cisco.com>
References: <200708080045.l780jE9E004667@neteffect.com>
	<200708081830.20129.mb@bu3sch.de> <46B9F054.4030000@garzik.org>
	<200708081843.36370.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>,
	ggrundstrom@neteffect.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:2858 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757564AbXHHQqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 12:46:17 -0400
In-Reply-To: <200708081843.36370.mb@bu3sch.de> (Michael Buesch's message of "Wed, 8 Aug 2007 18:43:36 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > The barrier/ordering issue however might be a critical thing,
 > when using __raw_XXX. So one must always mmiowb() after such a write.

Not mmiowb() -- that is for ordering between CPUs, eg on systems like
Altix where PCI transactions might get reordered in the system fabric
before reaching the PCI bus.

You need a full wmb() to order between __raw_writel()s.

 - R.
