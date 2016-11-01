From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: enhance tcp collapsing
Date: Tue, 01 Nov 2016 10:47:47 -0700
Message-ID: <1478022467.7065.347.camel@edumazet-glaptop3.roam.corp.google.com>
References: <VI1PR0502MB29577BA8C670D1379CC4F1B7D4A10@VI1PR0502MB2957.eurprd05.prod.outlook.com>
         <1478007189.7065.331.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478014346.7065.342.camel@edumazet-glaptop3.roam.corp.google.com>
         <CADVnQymN18JsVSX-0wT3qSuP9+pB8_8js26SQ_XgRF1jM6raDw@mail.gmail.com>
         <1478021994.7065.343.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
        Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33224 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752861AbcKARrt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 13:47:49 -0400
Received: by mail-pf0-f196.google.com with SMTP id a136so8821183pfa.0
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 10:47:48 -0700 (PDT)
In-Reply-To: <1478021994.7065.343.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-01 at 10:39 -0700, Eric Dumazet wrote:

> Thanks Neal.
> 
> David please hold this patch, further tests show an issue I need to
> track and fix.

The issue is that the right skb can be a FIN packet with no data,
merged to a left skb with frag(s).

Thus I need to call skb_copy_bits() only if there is something to copy,
otherwise skb_put() can BUG_ON in SKB_LINEAR_ASSERT(), even if @len is
0.
