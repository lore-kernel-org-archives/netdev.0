From: Tom Herbert <tom@herbertland.com>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Tue, 5 Sep 2017 14:13:05 -0700
Message-ID: <CALx6S3698iBwLX3wXw8_rhHbhztLh-BAkkhn68=z=2FgbfTkZg@mail.gmail.com>
References: <20170830230409.15176-1-saeedm@mellanox.com> <87fuc7ong0.fsf@stressinduktion.org>
 <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
 <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
 <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
 <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
 <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
 <87pob6bmjv.fsf@stressinduktion.org> <CALx6S37wcp1om0Dwr1=-6jF=HkAuZj313pLJ7sVhgsyJ4yZDjg@mail.gmail.com>
 <8760cytnif.fsf@stressinduktion.org> <CALx6S34cOL4Gy9DMWnLV0iCVUYo+siMEeNNn9v5tBHr2P6yjYw@mail.gmail.com>
 <87k21ez6r9.fsf@stressinduktion.org> <CALx6S34aDER1Gzpcw+p7+yr91mjiixCh6gnawKSxy7zhVQz+6Q@mail.gmail.com>
 <87r2vls8hp.fsf@stressinduktion.org> <CALx6S345jR6UtAGju9TaPxAOMgkBG2RZ+eMWz80ix1joSmQCog@mail.gmail.com>
 <87fuc1q7en.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:35067 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752312AbdIEVNH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 17:13:07 -0400
Received: by mail-qt0-f169.google.com with SMTP id k2so15408627qte.2
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 14:13:07 -0700 (PDT)
In-Reply-To: <87fuc1q7en.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The situation with encapsulation is even more complicated:
>
> We are basically only interested in the UDP/vxlan/Ethernet/IP/UDP
> constellation. If we do the fragmentation inside the vxlan tunnel and
> carry over the skb hash to all resulting UDP/vxlan packets source ports,
> we are fine and reordering on the receiver NIC won't happen in this
> case. If the fragmentation happens on the outer UDP header, this will
> result in reordering of the inner L2 flow. Unfortunately this depends on
> how the vxlan tunnel was set up, how other devices do that and (I
> believe so) on the kernel version.
>
This really isn't that complicated. The assumption that an IP network
always delivers packets in order is simply wrong. The inventors of
VXLAN must have know full well that when you use IP, packets can and
eventually will be delivered out of order. This isn't just because of
fragmentation, there are many other reasons that packets can be
delivered OOO. This also must have been known when IP/GRE and any
other protocol that carries L2 over IP was invented. If OOO is an
issue for these protocols then they need to be fixed-- this is not a
concern with IP protocol nor the stack.

Tom
