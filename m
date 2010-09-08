From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Wed, 8 Sep 2010 16:49:27 -0700
Message-ID: <AANLkTimZ=i1=c3SaEsw2_ncWJenuOgoSmHpMuN_UiG4K@mail.gmail.com>
References: <1283986576.2428.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:64366 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140Ab0IHXt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 19:49:28 -0400
Received: by iwn5 with SMTP id 5so463544iwn.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 16:49:28 -0700 (PDT)
In-Reply-To: <1283986576.2428.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 8, 2010 at 3:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Use cmpxchg() to get rid of spinlocks in inet_add_protocol() and
> friends.
>
> inet_protos[] & inet6_protos[] are moved to read_mostly section
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

What's the benefit to this?  It's hard to imagine that add/deleting
protocols is highly contended.  On the other hand, a simple spinlock
is very easy to look at and verify correct, while this takes a little
more thought.
