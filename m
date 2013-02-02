From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v9 net-next 05/12] bridge: Add the ability to configure
 pvid
Date: Fri, 01 Feb 2013 21:22:38 -0500
Message-ID: <510C786E.5040406@redhat.com>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com> <1359748930-31475-6-git-send-email-vyasevic@redhat.com> <CAHXqBFKXEHjghyDe4UQs4inH55UzWcsz+eWAXR4qFiM7+4yVxw@mail.gmail.com> <CAHXqBFJ3FutyBGNAXPueWLqJncvzNqd69nTJc0nLgUqzFMTWjw@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8357 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756721Ab3BBCWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 21:22:43 -0500
In-Reply-To: <CAHXqBFJ3FutyBGNAXPueWLqJncvzNqd69nTJc0nLgUqzFMTWjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2013 08:15 PM, Micha=B3 Miros=B3aw wrote:
> 2013/2/2 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
>> 2013/2/1 Vlad Yasevich <vyasevic@redhat.com>:
>>> A user may designate a certain vlan as PVID.  This means that
>>> any ingress frame that does not contain a vlan tag is assigned to
>>> this vlan and any forwarding decisions are made with this vlan in m=
ind.
>> [...]
>>>   struct net_port_vlans {
>>>          u16                             port_idx;
>>> +       u16                             pvid;
>>
>> I'm confused about the implementation. I would expect pvid field in
>> net_bridge_port and adding a tag if it isn't there on ingress path.
>> The rest would be just like without PVIDs. But here you pvid field t=
o
>> net_port_vlans, and don't do anything with it in receive nor transmi=
t
>> path. Does it work? What am I missing?
>
> Found the answer in next patch (you should merge #5 and #6).

It was split for incremental testing.  #5 added the ability to set and
delete it without impacting anything.  #6 added the actual work that=20
pvid does.

> Still,
> the implementation looks overly complicated. If you force the packet
> to canonical form on ingress (keeping outer tag in skb->vlan_tci, and
> setting skb->vlan_tci =3D pvid if there is no tag) the code should ge=
t
> simpler.

What if there is no outer tag?  That's what the ingress code is doing.
If there is no outer tag, pvid is written to vlan_tci.  If there was
outer tag in vlan_tci, it's left alone.  This way at the end of ingress
vlan_tci is always set.
At egress, we grab that tag and compare it against pvid if any.  If it
matches, it's stripped.  If it doesn't, we output with the tag thus
adding the header.

The only thing I can simplify is grab the tci directly at egress, but
that's what the code will do anyway.

-vlad

>
> Best Regards,
> Micha=B3 Miros=B3aw
>
