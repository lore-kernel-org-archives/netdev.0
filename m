From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Mon, 04 Sep 2017 11:37:21 +0200
Message-ID: <87shg2by9a.fsf@stressinduktion.org>
References: <20170830230409.15176-1-saeedm@mellanox.com>
        <87fuc7ong0.fsf@stressinduktion.org>
        <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
        <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
        <CALzJLG-KgwRXODJ8BghrYzhdQYtwEM1N1UVwsg+49UiAWbb8uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38023 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753364AbdIDJh2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 05:37:28 -0400
In-Reply-To: <CALzJLG-KgwRXODJ8BghrYzhdQYtwEM1N1UVwsg+49UiAWbb8uQ@mail.gmail.com>
        (Saeed Mahameed's message of "Sat, 2 Sep 2017 21:07:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Saeed Mahameed <saeedm@dev.mellanox.co.il> writes:

[...]

> On Sat, Sep 2, 2017 at 6:32 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> Sorry, I think I am still confused.
>>
>> I just want to make sure that you don't use the first nibble after the
>> mpls bottom of stack label in any way as an indicator if that is an IPv4
>> or IPv6 packet by default. It can be anything. The forward equivalence
>> class tells the stack which protocol you see.
>>
>> If you match on the first nibble behind the MPLS bottom of stack label
>> the '4' or '6' respectively could be part of a MAC address with its
>> first nibble being 4 or 6, because the particular pseudowire is EoMPLS
>> and uses no control world.
>>
>> I wanted to mention it, because with addition of e.g. VPLS this could
>> cause problems down the road and should at least be controllable? It is
>> probably better to use Entropy Labels in future.
>>
>
> Hi Hannes,
>
> I see your concern now, but still it has nothing to do with the
> driver, the whole change is only to simplify driver code to not push
> full blown matching steering rules into the HW, and simply replace it
> with a one bit command.

Sorry, I very much got the impression from the cover letter plus the
descriptions of the patches.

> Regarding your concern, I will need to check with the HW guys and
> review the processing algorithm that identifies IP packets over MPLs,
> and will get back to you.
>
> if there is really a problem, then yes, we might need to make it
> controllable ..

Thanks for looking into this. I do think it can be added as a feature
but I very much think such logic should be disabled by default.

Thanks,
Hannes
