From: David Miller <davem@davemloft.net>
Subject: Re: TG3 data corruption (TSO ?)
Date: Sat, 09 Sep 2006 02:22:28 -0700 (PDT)
Message-ID: <20060909.022228.41644790.davem@davemloft.net>
References: <9EAEC3B2-260E-444E-BCA1-3C9806340F65@kernel.crashing.org>
	<1157745256.5344.8.camel@rh4>
	<1157751962.31071.102.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, segher@kernel.crashing.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23994
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751082AbWIIJVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 05:21:55 -0400
To: benh@kernel.crashing.org
In-Reply-To: <1157751962.31071.102.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 09 Sep 2006 07:46:02 +1000

> I don't think that in general, you have ordering guarantees between
> cacheable and non-cacheable stores unless you use explicit barriers.

In fact, on most systems you absolutely do have ordering between
MMIO and memory accesses.

So you are making an extremely poor engineering decision
by trying to fixup all the drivers to match PowerPC's
semantics.  I think a smart engineer would decrease his
debugging burdon, by matching his platform's MMIO accessors
such that it matches what other platforms do and therefore
inheriting the testing coverage provided by all platforms.

Otherwise you will be hunting down these kinds of memory
barrier issues forever.
