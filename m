From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v3 net-next 7/8] geneve: Consolidate Geneve functionality
 in single module.
Date: Tue, 25 Aug 2015 13:54:35 -0700
Message-ID: <CALnjE+ri3yy7xS5NeS+FHzby4LH--6FAXbWS73CkiBYPfVMs4A@mail.gmail.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
	<1440438195-5695-8-git-send-email-pshelar@nicira.com>
	<CAEP_g=84tg9nPE-PmmPF_rVW_0ctAmjZj-fxRP-Puf9=Da0++g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:32972 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531AbbHYUyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 16:54:35 -0400
Received: by igfj19 with SMTP id j19so21963806igf.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 13:54:35 -0700 (PDT)
In-Reply-To: <CAEP_g=84tg9nPE-PmmPF_rVW_0ctAmjZj-fxRP-Puf9=Da0++g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 12:03 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Mon, Aug 24, 2015 at 10:43 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>> index c05bc13..8eb875d 100644
>> --- a/drivers/net/geneve.c
>> +++ b/drivers/net/geneve.c
>> @@ -492,36 +813,36 @@ static int geneve_configure(struct net *net, struct net_device *dev,
> [...]
>> +       gs = geneve_find_sock(gn, geneve->dst_port);
>> +       if (gs) {
>> +               if (metadata) {
>> +                       if (gs->collect_md)
>> +                               return -EEXIST;
>> +                       else
>> +                               return -EPERM;
>> +               } else {
>> +                       if (gs->collect_md)
>> +                               return -EPERM;
>> +
>> +                       t = geneve_lookup(gn, htons(dst_port),
>> +                                         rem_addr, geneve->vni);
>> +                       if (t)
>> +                               return -EBUSY;
>> +               }
>> +       }
>
> I like the new structure but unfortunately, I think there is a race.
> If two devices are created with conflicting configurations but neither
> is brought up then creation of both devices will succeed. However,
> when the second one is brought up, it will silently collide with the
> first.

geneve tunnel is added to hash table during configure time. So the
lookup does not have any dependency on device up or down state. The
Lookup and hash table updates are done under rtnl lock.
