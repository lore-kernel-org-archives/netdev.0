From: Tom Herbert <tom@herbertland.com>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Mon, 4 Sep 2017 10:11:21 -0700
Message-ID: <CALx6S34cOL4Gy9DMWnLV0iCVUYo+siMEeNNn9v5tBHr2P6yjYw@mail.gmail.com>
References: <20170830230409.15176-1-saeedm@mellanox.com> <87fuc7ong0.fsf@stressinduktion.org>
 <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
 <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
 <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
 <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
 <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
 <87pob6bmjv.fsf@stressinduktion.org> <CALx6S37wcp1om0Dwr1=-6jF=HkAuZj313pLJ7sVhgsyJ4yZDjg@mail.gmail.com>
 <8760cytnif.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:35210 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753910AbdIDRLX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 13:11:23 -0400
Received: by mail-qt0-f173.google.com with SMTP id k2so4082411qte.2
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2017 10:11:23 -0700 (PDT)
In-Reply-To: <8760cytnif.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The problem is that you end up having two streams, one fragmented and
> one non-fragmented, but actually they belong to the same stream. It is
> known to break stuff, see:
>
> <https://patchwork.ozlabs.org/patch/59235/>
>
> I would agree with you, but we can't break existing setups,
> unfortunately.
>
I'm not sure what "existing setups" means here. If this is referring
to the Internet then out of order packets and fragments abound-- any
assumption of in order delivery for IP packets is useless there.

Btw, TCP has exactly the same problem in this regard that UDP has with
regard to fragmentation. The reason that TCP isn't considered an issue
is the assumption that TCP will do PMTU discovery and set DF (I would
bet that devices don't actually check for DF and vendors don't test
when it's not set!).

Tom
