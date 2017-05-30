From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/4] net/flow_dissector: add support for
 dissection of misc ip header fields
Date: Tue, 30 May 2017 09:06:11 -0700
Message-ID: <CALx6S35Tkxc=PkdvpQWWWKgdBAOP5nmhCh1bP8LH9ochgG4ubQ@mail.gmail.com>
References: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com>
 <1495718679-20693-2-git-send-email-ogerlitz@mellanox.com> <CALx6S36uJrFA+TO7RDaRAxZi0vuEEc90_TnWP8a2yNP+V3X2qQ@mail.gmail.com>
 <CAJ3xEMgsYi_=0Sv7Wd9GajN5Oym3dKdw3QNDpU9jJR+T6z3Pmw@mail.gmail.com>
 <CALx6S35LoybyU-NN8RTk4YMOmuOZTkJeZ6GVBnWbX6rtd2uM6Q@mail.gmail.com> <20170530131029.GD1838@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34081 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750930AbdE3QGN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 12:06:13 -0400
Received: by mail-wm0-f67.google.com with SMTP id d127so26056866wmf.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 09:06:12 -0700 (PDT)
In-Reply-To: <20170530131029.GD1838@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 30, 2017 at 6:10 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Sat, May 27, 2017 at 07:18:45PM CEST, tom@herbertland.com wrote:
>>On Sat, May 27, 2017 at 9:31 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Thu, May 25, 2017 at 7:22 PM, Tom Herbert <tom@herbertland.com> wrot=
e:
>>>> On Thu, May 25, 2017 at 6:24 AM, Or Gerlitz <ogerlitz@mellanox.com> wr=
ote:
>>>>> Add support for dissection of ip tos and ttl and ipv6 traffic-class
>>>>> and hoplimit. Both are dissected into the same struct.
>>>
>>>>> Uses similar call to ip dissection function as with tcp, arp and othe=
rs.
>>>
>>>
>>>>> +/**
>>>>> + * struct flow_dissector_key_ip:
>>>>> + * @tos: tos
>>>>> + * @ttl: ttl
>>>>> + */
>>>>> +struct flow_dissector_key_ip {
>>>>> +       __u8    tos;
>>>>> +       __u8    ttl;
>>>>> +};
>>>>> --- a/net/core/flow_dissector.c
>>>>> +++ b/net/core/flow_dissector.c
>>>
>>>>> +static void
>>>>> +__skb_flow_dissect_ipv4(const struct sk_buff *skb,
>>>>> +                       struct flow_dissector *flow_dissector,
>>>>> +                       void *target_container, void *data, const str=
uct iphdr *iph)
>>>>> +{
>>>>> +       struct flow_dissector_key_ip *key_ip;
>>>>> +
>>>>> +       if (!dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_IP=
))
>>>>> +               return;
>>>>> +
>>>>> +       key_ip =3D skb_flow_dissector_target(flow_dissector,
>>>>> +                                          FLOW_DISSECTOR_KEY_IP,
>>>>> +                                          target_container);
>>>>> +       key_ip->tos =3D iph->tos;
>>>>> +       key_ip->ttl =3D iph->ttl;
>>>>
>>>> In an encapsulation this returns the tos and ttl of the encapsulated
>>>> packet. Is that really useful to the caller? Seems more likely that
>>>> they need the outer tos and ttl for forwarding.
>>>
>>> In what we are dealing with, classification is carried after the
>>> packet is decapsulated by the shared tunnel device. So even today,e.g
>>> for the src/dst IP, the dissection is carried on what were the inner
>>> fields before decap.
>>>
>>Or,
>>
>>I think the problem is I don't know what you're dealing with. The only
>>thing I can derive from the commit log is that tos and ttl are being
>>extracted, but I don't know why they are needed. I do know this is
>>adding complexity to an already overly complex function, and this
>>introduces new conditionals and code into the primary use case of
>>flow_dissector which is to create a key for deriving skb->hash. I
>>don't see that the cost of this patch has been justified.
>
> Tom, we have been over this multiple times. The decision DaveM made at
> the time I was pushing cls_flower was to have one shared dissection code
> (I originally had a separate dissector inside cls_flower). And I
> agree with that decision. It was a bit painful to work out the
> flow_dissector in a generic way, but it was worth the efford.
>is i
> So when we need to dissect something new for cls_flower, we put it here.
> flow_dissector is now miles away from being just a plain
> "creator of the key to derive skb->hash".
>
Jiri,

The commit log does not mention cls_flower. There are no test results
given for the impact of the patch. There is no description why tos and
ttl are being added as opposed to id, flags, or IP options for that
matter.

Tom

> Ji=C5=99=C3=AD
