From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] inet: get rid of central tcp/dccp listener
 timer
Date: Thu, 19 Mar 2015 19:41:59 -0700
Message-ID: <1426819319.25985.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAADnVQKw8rDF9p-bjjr4TKp_5M_XTX-7NcifLqyLXLne2E8uoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:36164 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbbCTCl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 22:41:57 -0400
Received: by iedm5 with SMTP id m5so18408331ied.3
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 19:41:57 -0700 (PDT)
In-Reply-To: <CAADnVQKw8rDF9p-bjjr4TKp_5M_XTX-7NcifLqyLXLne2E8uoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-19 at 19:26 -0700, Alexei Starovoitov wrote:

> > This is ~100 times more what we could achieve before this patch.
> 
> wow. That is impressive!
> I guess timers do scale to millions.
> Outstanding.

Note that my goal is go get 1000 times, when we no longer take listener
lock ;)

When req sock is hashed into ehash, this means the ACK packet coming
from the client will find it while doing the normal RCU lookup.

ehash is protected by an array of spinlocks, so it scales.

Ideally, we should allow say 10 million request socks, so that SYNCOOKIE
mode is only a real emergency thing.

Thanks.
