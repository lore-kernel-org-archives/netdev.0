From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Fri, 12 Jun 2009 10:17:27 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0906121014010.13365@gentwo.org>
References: <ada1vps4u9e.fsf@cisco.com> <20090609.215719.214969588.davem@davemloft.net> <alpine.DEB.1.10.0906111107390.29827@gentwo.org> <20090611.165856.108387598.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdreier@cisco.com, netdev@vger.kernel.org, yosefe@Voltaire.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:57935 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751779AbZFLORb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 10:17:31 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E1E0482C4E5
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2009 10:33:17 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id quEjmTQTo3cS for <netdev@vger.kernel.org>;
	Fri, 12 Jun 2009 10:33:17 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BCCFB82C653
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2009 10:33:11 -0400 (EDT)
In-Reply-To: <20090611.165856.108387598.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jun 2009, David Miller wrote:

> > Umm?? My patch does that....
>
> No it does not.  It eliminates a limit on the generic intermediate
> queue.  It did no blocking, no sleeping, or the process when it
> joined the group.

What intermediate queue? The check in the IPoIB layuer was simply for
packets queued on a socket. Are you talking about the TX ring?

> I was suggesting to block the process, at socket context time, when it
> joins a multicast group.  That way it wouldn't be able to do any sends
> until IPoIB could resolve the multicast join.

My patch blocks the process when the queue has filled up. It blocks when
the queue has reached sk_sndbuf

The join occurs and then the app continues sending packets that are
queued until the queue limits have been reached. Then the process blocks.

It would be better to block earlier but this also does the trick.
