From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 08:35:13 -0800
Message-ID: <CALx6S37QT-3W5psz0f2bf+RTzt09AysCtwTQmzZsHS_g6uo5ZA@mail.gmail.com>
References: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com>
 <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net> <CAJ3xEMijwHpWfxUFcaCiAkP_0P8R2u6Cv4L=Vc3b_dPf+beOBg@mail.gmail.com>
 <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com>
 <7810166.196078.1487842556962.JavaMail.zimbra@tpip.net> <20170223140012.GA4462@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andreas Schultz <aschultz@tpip.net>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        laforge <laforge@gnumonks.org>, netdev <netdev@vger.kernel.org>,
        timo lindhorst <timo.lindhorst@travelping.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:33352 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbdBWQfP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 11:35:15 -0500
Received: by mail-qt0-f171.google.com with SMTP id b16so33011507qte.0
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 08:35:14 -0800 (PST)
In-Reply-To: <20170223140012.GA4462@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 6:00 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Thu, Feb 23, 2017 at 10:35:56AM +0100, Andreas Schultz wrote:
>> ----- On Feb 22, 2017, at 10:47 PM, Tom Herbert tom@herbertland.com wrote:
> [...]
>> > This shouldn't be taken as a HW requirement and it's unlikely we'd add
>> > explicit GTP support in flow_dissector. If we can't get entropy in the
>> > UDP source port then IPv6 flow label is a potential alternative (so
>> > that should be supported in NICs for RSS).
>> >
>> > I'll also reiterate my previous point about the need for GTP testing--
>> > in order for us to be able to evaluate the GTP datapath for things
>> > like performance or how they withstand against DDOS we really need an
>> > easy way to isolate the datapath.
>>
>> GTP as specified is very unsecure by definition. It is meant to be run
>> only on *private* mobile carrier and intra mobile carrier EPC networks.
>> Running it openly on the public internet would be extremly foolish.
>>
>> There are some mechanisms in GTPv1-C on how to handle overload and
>> more extensive mechanisms in GTPv2-C for overload handling. The basic
>> guiding principle is to simply drop any traffic that it can't handle.
>>
>> Anyhow, I havn't seen anything in 3GPP or GSMA documents that deals
>> with DDOS.
>>
>> There are guidelines like the GSMA's IR.88 that describe how the intra
>> carrier roaming should work and what security measures should be
>> implemented.
>>
>> Traffic coming in at Gi/SGi or form the UE could create a DDOS on tunnel.
>> However, on the UE side you still have the RAN (eNODE, SGSN, S-GW) or
>> an ePDG that has to apply QoS and thereby limit traffic. On the Gi/SGi
>> side side you have the PCEF that does the same.
>>
>> So in a complete 3GPP node (GGSN, P-GW) that uses the GTP tunnel
>> implementation, malicious traffic should be blocked before it can reach
>> the tunnel.
>>
>> And as I stated before, the GTP tunnel module is not supposed to be
>> use without any of those components. So the DDOS concern should not
>> be handled at the tunnel level.
>
> I think that Tom's point is that this tunnel driver will have to deal
> with DDOS scenarios anyway, because reality is that you can't always
> block it before it can reach the tunnel.
>
Right, if only we had a dime for every time someone thought their
perimeter security was sufficient only to be proven wrong!
