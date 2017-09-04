From: Tom Herbert <tom@herbertland.com>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Mon, 4 Sep 2017 11:56:00 -0700
Message-ID: <CALx6S34aDER1Gzpcw+p7+yr91mjiixCh6gnawKSxy7zhVQz+6Q@mail.gmail.com>
References: <20170830230409.15176-1-saeedm@mellanox.com> <87fuc7ong0.fsf@stressinduktion.org>
 <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
 <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
 <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
 <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
 <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
 <87pob6bmjv.fsf@stressinduktion.org> <CALx6S37wcp1om0Dwr1=-6jF=HkAuZj313pLJ7sVhgsyJ4yZDjg@mail.gmail.com>
 <8760cytnif.fsf@stressinduktion.org> <CALx6S34cOL4Gy9DMWnLV0iCVUYo+siMEeNNn9v5tBHr2P6yjYw@mail.gmail.com>
 <87k21ez6r9.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36530 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753953AbdIDS4B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 14:56:01 -0400
Received: by mail-qk0-f178.google.com with SMTP id z143so4603023qkb.3
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2017 11:56:01 -0700 (PDT)
In-Reply-To: <87k21ez6r9.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 4, 2017 at 10:57 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Tom,
>
> Tom Herbert <tom@herbertland.com> writes:
>
>>> The problem is that you end up having two streams, one fragmented and
>>> one non-fragmented, but actually they belong to the same stream. It is
>>> known to break stuff, see:
>>>
>>> <https://patchwork.ozlabs.org/patch/59235/>
>>>
>>> I would agree with you, but we can't break existing setups,
>>> unfortunately.
>>>
>> I'm not sure what "existing setups" means here. If this is referring
>> to the Internet then out of order packets and fragments abound-- any
>> assumption of in order delivery for IP packets is useless there.
>
> Network cards don't know where traffic originates from, even on the same
> card. Clouds nowadays try to convince everyone to virtualize existing
> workloads. So I *assume* that at least for traffic that seems to be in
> one L2 domain out of order should not occur or things will break.
>
> Ethernet for a long time appeared to do very much in order delivery and
> guarantees that. Thus for people it appeared that UDP packets are also
> strictly in order. Encapsulating Ethernet inside UDP thus must preserve
> those properties, especially if used for virtualization. Unfortunately
> fragmentation happens and the stack has to deal with it somehow.
>
There is absolutely no requirement in IP that packets are delivered in
order-- there never has been and there never will be! If the ULP, like
Ethernet encapsulation, requires in order deliver then it needs to
implement that itself like TCP, GRE, and other protocols ensure that
with sequence numbers and reassembly. All of these hoops we do make
sure that packets always follow the same path and are always in order
are done for benefit of middlebox devices like stateful firewalls that
have force us to adopt their concept of network architecture-- in the
long run this is self-defeating and kills our ability to innovate.

I'm not saying that we shouldn't consider legacy devices, but we
should scrutinize new development or solutions that perpetuate
incorrect design or bad assumptions.

Tom
