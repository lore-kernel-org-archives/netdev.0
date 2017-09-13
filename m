From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 2/2] net/sched: allow
 flower to match tunnel options
Date: Wed, 13 Sep 2017 13:03:43 +0300
Message-ID: <CAJ3xEMj1prPRij-Dib96oZMik_k0DzEuXcxi7TbVeSwt9WnDsQ@mail.gmail.com>
References: <1505226037-2758-1-git-send-email-simon.horman@netronome.com>
 <1505226037-2758-3-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgfkpJCfZX-7jaeYtoWTSQQZ6gu8_jSFgcXpzTBpdijQw@mail.gmail.com> <20170913092511.GA27555@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33078 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751455AbdIMKDp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 06:03:45 -0400
Received: by mail-oi0-f65.google.com with SMTP id z73so5701198oia.0
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 03:03:44 -0700 (PDT)
In-Reply-To: <20170913092511.GA27555@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 13, 2017 at 12:25 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> On Tue, Sep 12, 2017 at 11:23:55PM +0300, Or Gerlitz wrote:
>> On Tue, Sep 12, 2017 at 5:20 PM, Simon Horman
>> <simon.horman@netronome.com> wrote:
>> > Allow matching on options in tunnel headers.
>> > This makes use of existing tunnel metadata support.
>>
>> Simon,
>>
>> This patch is about matching on tunnel options, right? but
>>
>> > Options are a bytestring of up to 256 bytes.
>> > Tunnel implementations may support less or more options,
>> > or no options at all.
>> >
>> >  # ip link add name geneve0 type geneve dstport 0 external
>> >  # tc qdisc add dev eth0 ingress
>> >  # tc qdisc del dev eth0 ingress; tc qdisc add dev eth0 ingress
>> >  # tc filter add dev eth0 protocol ip parent ffff: \
>> >      flower indev eth0 \
>> >         ip_proto udp \
>> >         action tunnel_key \
>> >             set src_ip 10.0.99.192 \
>> >             dst_ip 10.0.99.193 \
>> >             dst_port 4789 \
>> >             id 11 \
>> >             opts 0102800100800022 \
>> >     action mirred egress redirect dev geneve0
>>
>> the example here is on how to use tunnel options in the tunnel set key actions..
>>
>> And the other way around in the other patch... the patch is about the
>> tunnel key set action and the example shows how to match that in
>> flower... I guess you want to swap the relevant of the change log.
>
> Yes, it seems so. Sorry about that.

no worries, you can do the swap, but before that

>> Anyway, is there any human readable/understandable representation of
>> these options? e.g what does 0102800100800022 means for geneve?

> Thanks, I had not thought of that. My feeling is that could
> be added to the tc tool as follow-up work.

could you spend few words on the nature of these options now when we review
the kernel patches? I guess this is somehow related to protocols such
as geneve and vxlan-gpe  -- it would be good if you elaborate on that
a bit, does
the kernel does any usage with these options beyond matching on them or stiching
them to packet headers?

Or.
