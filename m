From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Thu, 11 Jun 2009 11:07:52 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0906111107390.29827@gentwo.org>
References: <adaocsx3zaa.fsf@cisco.com> <20090609.174504.114047526.davem@davemloft.net> <ada1vps4u9e.fsf@cisco.com> <20090609.215719.214969588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdreier@cisco.com, netdev@vger.kernel.org, yosefe@Voltaire.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:35657 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754773AbZFKPIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 11:08:01 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0A1DE82C417
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 11:23:42 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ido09a3Vir9G for <netdev@vger.kernel.org>;
	Thu, 11 Jun 2009 11:23:41 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DA90A82C43C
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 11:23:35 -0400 (EDT)
In-Reply-To: <20090609.215719.214969588.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Jun 2009, David Miller wrote:

> From: Roland Dreier <rdreier@cisco.com>
> Date: Tue, 09 Jun 2009 20:55:57 -0700
>
> > Hmm... how do I do that?  The interface gets an skb that it sees should
> > be sent to a multicast group that it is not a member of yet, and so it
> > fires off a request to join that group (as a send-only member).  How
> > does a netdev block the process that queued up a given skb to send?
> > Couldn't the packet have come through a local software bridge or
> > something like that, so the original process is long since lost to the
> > network stack?
>
> If a facility doesn't exist yet, we're going to have to create
> one.  It would need to do a downcall to the device when the
> user joins a multicast group on a socket, and then the device
> can do whatever magic is necessary to speak multicast immediately
> and sleep until it really is available for immediate use.

Umm?? My patch does that....

