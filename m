From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast
 messages
Date: Wed, 15 Apr 2009 15:17:33 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904151516380.18317@qirst.com>
References: <20090414182731.GD14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141447310.30596@qirst.com> <20090414204445.GB17196@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141740280.3973@qirst.com> <20090415110714.GA21448@hmsreliant.think-freely.org>
 <alpine.DEB.1.10.0904150841550.10217@qirst.com> <20090415142208.GB21448@hmsreliant.think-freely.org> <49E5F1FF.1000801@hp.com> <20090415155702.GC21448@hmsreliant.think-freely.org> <49E6063B.3040107@hp.com> <20090415163812.GD21448@hmsreliant.think-freely.org>
 <49E6172D.8080201@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:58572 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbZDOTYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 15:24:47 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 86E3382C25E
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:34:34 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vKGvmVZep2xD for <netdev@vger.kernel.org>;
	Wed, 15 Apr 2009 15:34:34 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6630F82C260
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:34:28 -0400 (EDT)
In-Reply-To: <49E6172D.8080201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Apr 2009, Vlad Yasevich wrote:

> Looking at BSD, which was the root of the original brokeness, they have it fixed.
> The code will skip sockets that are not members of a particular group.  So, we
> are trying really hard to stay bug-for-bug compatible with old implementations.

Ahh interesting. David: Could you say something on this?

> What's worse is that if you have a socket that doesn't care about any mulicast
> destinations (never did an ADD_MEMBERSHIP), it will still get multicast traffic if
> it bound to that port.
>
> We need to take into account the socket's multicast group list.

Right. The fix is pretty simple too since the infrastructure has been
there since the IGMPv3 updates.

