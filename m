From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] vxlan: synchronously and race-free destruction of
 vxlan sockets
Date: Fri, 08 Apr 2016 13:40:28 -0700
Message-ID: <1460148028.6473.446.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460041060-8619-1-git-send-email-hannes@stressinduktion.org>
	 <20160408185114.GA1920@localhost.localdomain>
	 <570814EF.8060308@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34633 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758837AbcDHUka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:40:30 -0400
Received: by mail-pf0-f170.google.com with SMTP id c20so82204207pfc.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 13:40:30 -0700 (PDT)
In-Reply-To: <570814EF.8060308@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-08 at 22:30 +0200, Hannes Frederic Sowa wrote:
> Hi Marcelo,
> ng rtnl?
> 
> I thought about that and try not to use synchronize_rcu, but I don't see 
> any other way. Anyway, ndo_stop isn't really fast path and is used to 
> shut the interface down. Also since we have lwtunnels we don't really 
> need a lot of interfaces created and torn down.
> 
> But I could switch to synchronize_rcu_expedited here.
> 
> Also we have another synchronize_rcu during device dismantling, maybe we 
> can split ndo_stop into two callbacks, one preparing for stopping and 
> the other one after the synchronize_rcu when we safely can free resources.
> 
> I will investigate this but for the mean time I think this patch is 
> already improving things as user space can bind the socket again when 
> the dellink command returned.

Of course, we have synchronize_net() which specifically put in a single
point the knowledge (rtnl being held or not)
