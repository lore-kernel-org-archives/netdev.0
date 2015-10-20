From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 20 Oct 2015 12:39:50 +0100
Message-ID: <56262806.2090605@oracle.com>
References: <562594E1.8040403@oracle.com>	<1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>	<56261092.7080003@oracle.com> <20151020.042419.299487241092379193.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37745 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbbJTLkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 07:40:03 -0400
In-Reply-To: <20151020.042419.299487241092379193.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/10/2015 12:24, David Miller wrote:

> With two decades of precendence, applications will need to find a way
> to cope with the behavior on every existing Linux kernel out there.
>
> Even if we were to propose something here and change things, it won't
> be available on real sites for 6 months at a minimum, and only a an
> extremely small fraction of actual machines.
>
> It's more practical for userspace to cope with the bahvior.  This is
> simply because coping with current behavior will work on every Linux
> kernel on the planet, and also it won't require us to potentially
> break any existing setups.

Yes, as I said I think in practice about the best that can be done is to 
document the behaviour, although I think the assertion of their being 
millions of apps that would be affected is an over-estimate. Only MT 
apps that use accept() in one thread and shutdown() in another should be 
impacted, i.e mainly threaded apps that act as network service providers 
of one form or another.

But having said that, the behaviour of close() and poll() on sockets 
being used in accept() still looks incorrect.

-- 
Alan Burlison
--
