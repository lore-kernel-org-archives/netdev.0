From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 05/14] gtp: Remove special mtu handling
Date: Tue, 19 Sep 2017 11:12:44 -0700
Message-ID: <CALx6S34eUG1pb=oeJEr1_Gosb638NGyJZ9zPDLkM6wu+h9uVkQ@mail.gmail.com>
References: <20170919003904.5124-1-tom@quantonium.net> <20170919003904.5124-6-tom@quantonium.net>
 <20170919114205.z2txj6rwo2row7u4@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:46568 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751040AbdISSMq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 14:12:46 -0400
Received: by mail-qt0-f169.google.com with SMTP id s18so499037qta.3
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 11:12:45 -0700 (PDT)
In-Reply-To: <20170919114205.z2txj6rwo2row7u4@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 4:42 AM, Harald Welte <laforge@gnumonks.org> wrote:
> Hi Tom,
>
> On Mon, Sep 18, 2017 at 05:38:55PM -0700, Tom Herbert wrote:
>> Removes MTU handling in gtp_build_skb_ip4. This is non standard relative
>> to how other tunneling protocols handle MTU. The model espoused is that
>> the inner interface should set it's MTU to be less than the expected
>> path MTU on the overlay network. Path MTU discovery is not typically
>> used for modifying tunnel MTUs.
>
> The point of the kernel GTP module is to interoperate with existing
> other GTP implementations and the practises established by cellular
> operators when operating GTP in their networks.
>
> While what you describe (chose interface MTU to be less than the
> expected path MTU) is generally best practise in the Linux IP/networking
> world, this is not generally reflected in the cellular
> universe. You see quite a bit of GTP fragmentation due to the fact
> that the transport network simply has to deal with the MTU that has
> been established via the control plane between SGSN and MS/UE, without
> the GGSN even being part of that negotiation.
>
> Also, you may very well have one "gtp0" tunnel device at the GGSN,
> but you are establishing individual GTP tunnels to dozesn to hundreds of
> different SGSNs at operators all over the world.  You cannot reliably
> set the "gtp0" interface MTU to "the path MTU of the overlay network",
> as the overlay network is in fact different for each of the SGSNs you're
> talking to - and each may have a different path MTU.
>
> So unless I'm missing something, I would currently vote for staying with
> the current code, which uses the path MTU to the specific destination IP
> address (the SGSN).
>
Okay, I'll modify tnl_update_pmtu so we can call it from GTP and not
have to replicate that function. I suspect VXLAN might also what this
at some point.

Tom

> Regards,
>         Harald
>
> --
> - Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
> ============================================================================
> "Privacy in residential applications is a desirable marketing option."
>                                                   (ETSI EN 300 175-7 Ch. A6)
