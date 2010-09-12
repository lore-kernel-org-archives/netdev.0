From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Sun, 12 Sep 2010 12:45:34 +0200
Message-ID: <20100912104534.GA2056@del.dom.local>
References: <1283852248.2338.160.camel@edumazet-laptop>
 <20100910.125449.235704956.davem@davemloft.net>
 <20100911123140.GA1939@del.dom.local>
 <20100911.203002.193707453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61576 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842Ab0ILKpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 06:45:41 -0400
Received: by wyf22 with SMTP id 22so4962750wyf.19
        for <netdev@vger.kernel.org>; Sun, 12 Sep 2010 03:45:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100911.203002.193707453.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 11, 2010 at 08:30:02PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sat, 11 Sep 2010 14:31:40 +0200
> 
> > Otherwise seems OK, but I still would like to know the scenario
> > demanding this change.
> 
> I want to make sk_buff use list_head, including all uses such as
> frag_list et al.
> 
> If the frag_list chain can be shared, a doubly linked list cannot be
> used.
> 
> This is someting I've been gradually working on now for more than 2
> years :)

Hmm... Then the first message/changelog in this thread seems to
describe the future bug, only with doubly linked lists. If so, it was
a bit misleading to me ;-)

Then a few more questions:
1) if doubly linked lists really require such pskb_copying, isn't it
   all too costly?
2) why skb_clone isn't enough instead of pskb_copy?
3) since skb_clone has some cost too, why e.g. saving only the pointer
   to the tail of the list in skb_shared_info isn't enough?

Jarek P.
