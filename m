From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Tue, 02 Feb 2010 13:16:38 -0500
Message-ID: <1265134598.2861.191.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1265023437.2848.30.camel@edumazet-laptop>
	 <1265035970.2848.50.camel@edumazet-laptop>
	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>
	 <1265036548.2848.55.camel@edumazet-laptop>
	 <1265108690.2861.118.camel@tonnant> <1265110504.2861.135.camel@tonnant>
	 <1265129192.2861.141.camel@tonnant> <4B685756.8010107@trash.net>
	 <1265130426.2861.158.camel@tonnant>
	 <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:49552 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754272Ab0BBSRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 13:17:04 -0500
In-Reply-To: <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-02 at 19:58 +0200, Alexey Dobriyan wrote:

> Yes, moving to init_net-only function is fine.

So moving the "setup up fake conntrack" bits to init_init_net from
init_net still results in the panic, which means that the use count
really is dropping to zero and we really are trying to free it when
using multiple namespaces. Per ns is probably an easier way to go.

Just for kicks, I'll have it error out on attempting to free to see if I
can get this box to stay up for a while.

Jon.


