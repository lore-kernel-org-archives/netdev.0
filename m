From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Centralizing support for TCAM?
Date: Tue, 6 Sep 2016 07:17:10 -0400
Message-ID: <4e871929-b8fb-b1c9-6909-218460e21e76@mojatatu.com>
References: <57d4a2db-ca3b-909a-073a-52ecceb428f2@gmail.com>
 <b8323295-e3eb-48ca-7c82-ff40d222a743@gmail.com> <57C9C9BE.6040407@gmail.com>
 <20160903070950.GA1749@nanopsycho.orion>
 <20160906034450.GA34929@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, jiri@mellanox.com, idosh@mellanox.com,
        john.fastabend@intel.com, ast@kernel.org, davem@davemloft.net,
        ecree@solarflare.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35754 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933111AbcIFLRN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 07:17:13 -0400
Received: by mail-oi0-f53.google.com with SMTP id s131so27381527oie.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 04:17:12 -0700 (PDT)
In-Reply-To: <20160906034450.GA34929@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-05 11:44 PM, Alexei Starovoitov wrote:

> lol :)
> compiling bpf into fixed pipeline asic is definitely not easy.
> The problem with adding new cls classifieris and actions to match
> what configurable hw does isn't pretty either. The fixed pipeline
> isn't interesting beyond l2/l3 and flow-based hw features are mostly
> useless in the tor.

openflow cargo cult grew around those ACLs (before pragmatism
of table sizes and that there is more reality to networking
than some silly ACLs or defining everything as a table).
But that doesnt make things outside of L2/3 useless. A few
players like google are using those ASIC ACLs quiet effectively.

>I'm not against adding new classifiers, since it's
> better than sdk, but we won't be using such tc features either.

We are seeing use of those ACLs on TORs and spines (with tc). Yes, tiny
table spaces are a problem but new hardware allows for expansion
and people who use those tables are factoring in these issues.
You are not going to beat the performance numbers these things
offer. There is a lifespan of maybe 3-4 years where you are
not going to beat those numbers with s/ware without spending
more $ and space.

> Since this thread about tcam... my 0.02 here is it's pretty bad in
> the nic(host) due to power consumption and in the tor it's only good as
> a part of algorithmic lpm solutions. There it won't be even seen as tcam.
> Instead the fancy algorithms will use exact match + tcam + aux data to pack
> as many routes into such 'algorithmic lpm' as possible, so I cannot see
> what tcam as actual tcam can be good for.
>

Agreed on tcams.

cheers,
jamal
