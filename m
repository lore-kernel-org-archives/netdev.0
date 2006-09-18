From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Mon, 18 Sep 2006 14:37:05 +0400
Message-ID: <20060918103705.GB1096@ms2.inr.ac.ru>
References: <20060830100734.GA22235@isil.ipib.msu.ru> <20060904160045.GA15599@ms2.inr.ac.ru> <20060918.003110.88477231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:63379 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S965651AbWIRKqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 06:46:05 -0400
Received: from ms2.inr.ac.ru (minus.inr.ac.ru [194.67.69.97])
	by zeus1.kernel.org (8.13.7/8.13.1) with SMTP id k8IAim9k030865
	for <netdev@vger.kernel.org>; Mon, 18 Sep 2006 10:45:16 GMT
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060918.003110.88477231.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> It looks perfectly fine to me, would you like me to apply it
> Alexey?

Yes, I think it is safe.


Theoretically, there is one place where it can be not so good.
Good nagling tcp connection, which makes lots of small write()s,
will send MSS sized frames due to delayed ACKs. But if we ACK
each other segment, more segments will come out incomplete,
which could result in some decrease of throughput.

But the trap for this case was set 6 years ago. For unidirectional sessions
ACKs were sent not even each second segment, but each small segment. :-)
This did not show any problems for those 6 years. I guess it means
that the problem does not exist.

Alexey
