From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce skb overhead in selected places
Date: Wed, 25 Jan 2017 13:40:12 -0800
Message-ID: <1485380412.5145.59.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485298656.16328.355.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170125.131717.489451306351372553.davem@davemloft.net>
         <1485369532.5145.50.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170125.140302.1425628250874176845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33935 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751803AbdAYVkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 16:40:14 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so15130781pfb.1
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 13:40:14 -0800 (PST)
In-Reply-To: <20170125.140302.1425628250874176845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 14:03 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 25 Jan 2017 10:38:52 -0800
> 
> > Do you think we could change __pskb_pull_tail() right away and fix the
> > few places that would break, or should we add various helpers with extra
> > parameters to take a safe route ?
> 
> It should always be safe as long as we see no socket attached on RX,
> right?
> 
> That's the only real case where truesize adjustments can cause trouble.
Queue can be virtual, as for xmit path, tracking skb->truesize in
sk->sk_wmem_alloc.

If a layer calls pskb_may_pull(), we can not change skb->truesize
without also changing skb->sk->sk_wmem_alloc, or sock_wfree() will
trigger bugs.
