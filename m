From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Sat, 14 Jan 2017 16:29:18 +0100
Message-ID: <20170114152918.GC1886@nanopsycho.orion>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
 <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
 <20170108171902.GH1971@nanopsycho>
 <5873D523.4030301@gmail.com>
 <68e41fe4-5c4c-e159-fbfc-17d06638707d@mojatatu.com>
 <20170114144855.GA1886@nanopsycho.orion>
 <de59c019-8a7d-6747-ddc1-9a21f40d3e04@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35799 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751034AbdANP3o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 10:29:44 -0500
Received: by mail-wm0-f65.google.com with SMTP id d140so2596716wmd.2
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 07:29:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <de59c019-8a7d-6747-ddc1-9a21f40d3e04@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jan 14, 2017 at 04:03:17PM CET, jhs@mojatatu.com wrote:
>On 17-01-14 09:48 AM, Jiri Pirko wrote:
>> Sat, Jan 14, 2017 at 01:56:35PM CET, jhs@mojatatu.com wrote:
>
>
>> > I think the feature makes a lot of sense (as is the action variant).
>> > But can we make it:
>> > a) fixed size
>> 
>> Can you elaborate on why is this needed?
>> 
>
>My experience with the action bits its easier to debug
>and enforces some discipline to not abuse the amount of RAM used.
>If you have 1M rules, one extra 128M is easier on the system than
>a few Gigs.

Fair. So could this be done like IFLA_PHYS_SWITCH_ID and
IFLA_PHYS_PORT_ID. They can have variable size, max is MAX_PHYS_ITEM_ID_LEN

We can let user to pass arbitrary len up to 16 bytes. This has benefit in
fact that if in future this needs to be extended to say 32 bytes, it is
backward compatible. We just change the check in kernel.


>
>> 
>> > b) apply to all classifiers
>> > c) please post a usage example via iproute2/tc
>> > 
>> > I am going to post the action variant in the next while - will do some more
>> > testing first.
>> 
>> I believe we have to make the cls and ats cookies exactly the same.
>> 
>
>Probably - they are both needed. See the patch I just posted.
>
>cheers,
>jamal
>
