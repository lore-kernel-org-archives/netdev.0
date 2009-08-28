From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Fri, 28 Aug 2009 16:09:38 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908281606340.11722@gentwo.org>
References: <alpine.DEB.1.10.0908280948320.3747@gentwo.org> <20090828.122459.245170385.davem@davemloft.net> <alpine.DEB.1.10.0908281553190.17784@gentwo.org> <20090828.130309.225603635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sri@us.ibm.com, dlstevens@us.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:35572 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752138AbZH1UJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 16:09:44 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1C41982C804
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 16:10:58 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0W8SlzD8ZDw7 for <netdev@vger.kernel.org>;
	Fri, 28 Aug 2009 16:10:53 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3AEBA82C7DE
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 16:10:53 -0400 (EDT)
In-Reply-To: <20090828.130309.225603635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2009, David Miller wrote:

> From: Christoph Lameter <cl@linux-foundation.org>
> Date: Fri, 28 Aug 2009 15:53:42 -0400 (EDT)
>
> > On Fri, 28 Aug 2009, David Miller wrote:
> >
> >> If you start incrementing tx_dropped here, people won't be able
> >> to tell they have a deteriorating cable or bad switch or similar.
> >
> > ?? The patch does not do that. That was extra stuff not covered by the
> > patch.
>
> Yes you did, you put a device tx_dropped counter bump into
> qdisc_drop().

Yes I did to that to test if I could propagate the counter somehow to the
device struct. But that did not work and showed that the qdisc structure
displayed by tc is different from the qdisc in use for the device. There
must be some other bug that causes the use of data from a different qdisc
to be displayed. Maybe device specific.

The patch definitely was never intended to be submitted for inclusion.
Just to show what the nature of the bug is.

