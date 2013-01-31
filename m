From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v7 net-next 03/12] bridge: Verify that a vlan is allowed
 to egress on give port
Date: Thu, 31 Jan 2013 15:17:45 -0500
Message-ID: <510AD169.8040206@redhat.com>
References: <1359601979-14942-1-git-send-email-vyasevic@redhat.com> <1359601979-14942-4-git-send-email-vyasevic@redhat.com> <CAHXqBFLQofoWPN9nfAKc6xumjzO3hu7ue3r=bHYerypAuRW0qw@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	shmulik.ladkani@gmail.com
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753918Ab3AaURt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 15:17:49 -0500
In-Reply-To: <CAHXqBFLQofoWPN9nfAKc6xumjzO3hu7ue3r=bHYerypAuRW0qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2013 03:03 PM, Micha=B3 Miros=B3aw wrote:
> 2013/1/31 Vlad Yasevich <vyasevic@redhat.com>:
>> When bridge forwards a frame, make sure that a frame is allowed
>> to egress on that port.
>
> For egress checks it might be better to have per-vlan bitmaps of port=
s
> instead. For unicast this doesn't really change anything, but for
> broadcast and multicast all ports are checked so reading all bits fro=
m
> one location is going to be cheaper.

But then one would have to locate that particular bitmap and now we are=
=20
back to a list/hash of vlans each containing port bitmap.  Considering=20
how strenuously Stephen wanted a bitmap of vlans, I'll leave it as is=20
for now.

>
> [...]
>> -static inline struct net_port_vlans *br_get_vlan_info(struct net_br=
idge *br)
>> +static inline struct net_port_vlans *br_get_vlan_info(
>> +                                               const struct net_bri=
dge *br)
>>   {
>>          return rcu_dereference(br->vlan_info);
>>   }
>>
>> -static inline struct net_port_vlans *nbp_get_vlan_info(struct net_b=
ridge_port *p)
>> +static inline struct net_port_vlans *nbp_get_vlan_info(
>> +                                               const struct net_bri=
dge_port *p)
>>   {
>>          return rcu_dereference(p->vlan_info);
>>   }
>
> Shouldn't this be in patch 1?

Sure.  'const' wasn't needed until this patch though, but I guess its=20
good practice.

Thanks for taking a look
-vlad
>
> Best Regards,
> Micha=B3 Miros=B3aw
>
