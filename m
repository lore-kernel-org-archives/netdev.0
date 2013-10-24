From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: 16% regression on 10G caused by TCP small queues
Date: Wed, 23 Oct 2013 21:45:57 -0700
Message-ID: <20131023214557.386aad1a@nehalam.linuxnetplumber.net>
References: <20131023192954.3dd9c784@nehalam.linuxnetplumber.net>
 <CADVnQymDr2K7z3yfKpW-H3R3W3NP+iuPQF2eMfeyS6dn-szdgA@mail.gmail.com>
 <CAOaVG15indAxBz7E-T+9MK03indiXBa0UhQZ5j6K5DxYP44Mxg@mail.gmail.com>
 <20131023.233816.1396918839771657154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, eric.dumazet@gmail.com,
	dave.taht@bufferbloat.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:56084 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136Ab3JXEqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 00:46:02 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so1999353pbc.17
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 21:46:01 -0700 (PDT)
In-Reply-To: <20131023.233816.1396918839771657154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Oct 2013 23:38:16 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Wed, 23 Oct 2013 20:09:49 -0700
> 
> > I will check 3.12, but what about users on 3.10 which is the LTS
> > kernel used by most distros?

3.12-rc6 gets line rate again (9.41 Gbit/sec)

> The fix will be backported to -stable, relax Stephen.

Sorry, thought sk_pacing_rate depended on FQ qdisc but it is other way around.
In which case doing merge of these two was sufficient to fix the problem.
With a minor manual fix up to tcp.h.


commit 95bd09eb27507691520d39ee1044d6ad831c1168
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Aug 27 05:46:32 2013 -0700

    tcp: TSO packets automatic sizing

commit c9eeec26e32e087359160406f96e0949b3cc6f10
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Sep 27 03:28:54 2013 -0700

    tcp: TSQ can use a dynamic limit
