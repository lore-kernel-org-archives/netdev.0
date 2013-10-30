From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 17:53:48 -0700
Message-ID: <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131029090849.GC5944@cpaasch-mac>
	 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, hkchu@google.com, mwdalton@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:43395 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab3J3Axy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:53:54 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so615425pbc.30
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 17:53:53 -0700 (PDT)
In-Reply-To: <20131029.194446.2215574000648693370.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 19:44 -0400, David Miller wrote:

> I do not like the idea of packet actions indirectly changing sysctl
> values, even if you document it sufficiently as you have here.
> 

Fair enough.

> I would suggest instead making it change in response to changes to
> ip_forward, as we do with per-device LRO settings.  This means that,
> like ip_forward, you should also make this sysctl a global + devinet
> per-device sysctl.
> 


> You might even emit a pr_info() when this logic triggers, and if you
> are ambitious enough keep track of the previous GRO sysctl state so
> you can restore it if ip_forward is set back to zero.

Ok, but this might take some time.

So should we apply the first fix to avoid the BUG_ON() ?
