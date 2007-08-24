From: David Miller <davem@davemloft.net>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 14:32:20 -0700 (PDT)
Message-ID: <20070824.143220.55503163.davem@davemloft.net>
References: <200708241559.17055.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, stefan.roscher@de.ibm.com
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751242AbXHXVcV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 17:32:21 -0400
In-Reply-To: <200708241559.17055.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Fri, 24 Aug 2007 15:59:16 +0200

> =A0 =A0It would be nice if it is possible to schedule queues to other=
 CPU's, or
> =A0 =A0at least to use interrupts to put the queue to another cpu (no=
t nice for=20
> =A0 =A0as you never know which one you will hit).=20
> =A0 =A0I'm not sure how bad the tradeoff would be.

Once the per-cpu NAPI poll queues start needing locks, much of the
gain will be lost.  This is strictly what we want to avoid.

We need real facilities for IRQ distribution policies.  With that none
of this is an issue.

This is also a platform specific problem with IRQ behavior, the IRQ
distibution scheme you mention would never occur on sparc64 for
example.  We use a fixed round-robin distribution of interrupts to
CPUS there, they don't move.

Each scheme has it's advantages, but you want a difference scheme here
than what is implemented and the fix is therefore not in the
networking :-)

=46urthermore, most cards that will be using multi-queue will be
using hashes on the packet headers to choose the MSI-X interrupt
and thus the cpu to be targetted.  Those cards will want fixed
instead of dynamic interrupt to cpu distribution schemes as well,
so your problem is not unique and they'll need the same fix as
you do.
