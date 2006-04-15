From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch] ipv4: initialize arp_tbl rw lock
Date: Sat, 15 Apr 2006 00:34:57 -0700 (PDT)
Message-ID: <20060415.003457.103031290.davem@davemloft.net>
References: <20060408100213.GA9412@osiris.boeblingen.de.ibm.com>
	<20060408.031404.111884281.davem@davemloft.net>
	<20060415072745.GA17011@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, akpm@osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fpavlic@de.ibm.com, davem@sunset.davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45721
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751573AbWDOHeo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 03:34:44 -0400
To: heiko.carstens@de.ibm.com
In-Reply-To: <20060415072745.GA17011@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Sat, 15 Apr 2006 09:27:45 +0200

> Tried to figure out what is causing the delays I experienced when I replaced
> module_init() in af_inet.c with fs_initcall(). After all it turned out that
> synchronize_net() which is basicically nothing else than synchronize_rcu()
> sometimes takes several seconds to complete?! No idea why that is...
> 
> callchain: inet_init() -> inet_register_protosw() -> synchronize_net()

The problem can't be rcu_init(), that gets done very early
in init/main.c

Maybe it's some timer or something else specific to s390?

It could also be that there's perhaps nothing to context
switch to, thus the RCU takes forever to "happen".
