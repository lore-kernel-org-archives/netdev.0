From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] ipv6: addrlabel: avoid dirtying ip6addrlbl_entry
Date: Mon,  9 Oct 2017 09:52:23 -0700
Message-ID: <20171009165225.7008-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:47071 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754255AbdJIQw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 12:52:29 -0400
Received: by mail-pf0-f170.google.com with SMTP id p87so5290203pfj.3
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 09:52:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The refcount on ip6addrlbl_entry is only used to make sure ip6addrlbl_entry
does not disappear while ip6addrlbl_get() is allocating an skb.

We can instead allocate skb first, then use RCU, so that we no longer need
to refcount these structures.

Eric Dumazet (2):
  ipv6: addrlabel: rework ip6addrlbl_get()
  ipv6: addrlabel: remove refcounting

 net/ipv6/addrlabel.c | 69 +++++++++++++---------------------------------------
 1 file changed, 17 insertions(+), 52 deletions(-)

-- 
2.14.2.920.gcf0c67979c-goog
