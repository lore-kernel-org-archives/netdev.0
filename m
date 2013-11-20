From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] packet: fix use after free race in send path when
 dev is released
Date: Wed, 20 Nov 2013 12:15:59 -0800
Message-ID: <1384978559.10637.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384902503-1588-1-git-send-email-dborkman@redhat.com>
	 <20131119.203451.358808893783927503.davem@davemloft.net>
	 <528C7319.5050309@redhat.com>
	 <20131120.150711.1110320732127884184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	noureddine@aristanetworks.com, greearb@candelatech.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:38782 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755030Ab3KTUQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:16:01 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so4021669pbb.37
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 12:16:00 -0800 (PST)
In-Reply-To: <20131120.150711.1110320732127884184.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-20 at 15:07 -0500, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>

> > Yep, will try if this approach works, in other words doing the earlier
> > exit via !po->running, plus deferring the dev_put() et al to RCU.
> 
> Thank you.  You might have to wrap the sendmsg path in an rcu lock
> sequence.

Note that dev_put() / dev_hold() are blazingly fast ;)
