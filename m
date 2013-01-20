From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V6 02/14] bridge: Add vlan filtering infrastructure
Date: Sun, 20 Jan 2013 12:59:22 -0500
Message-ID: <50FC307A.5090003@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com> <1358360289-23249-3-git-send-email-vyasevic@redhat.com> <CAHXqBFKg6Vp5=dprDYKON2LmshhX+nSPF7KRHiQmOS68PrQq-A@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, shemminger@vyatta.com, mst@redhat.com,
	shmulik.ladkani@gmail.com
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371Ab3ATR7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2013 12:59:30 -0500
In-Reply-To: <CAHXqBFKg6Vp5=dprDYKON2LmshhX+nSPF7KRHiQmOS68PrQq-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2013 08:57 PM, Micha=B3 Miros=B3aw wrote:
> 2013/1/16 Vlad Yasevich <vyasevic@redhat.com>:
> [...]
>> --- /dev/null
>> +++ b/net/bridge/br_vlan.c
> [...]
>> +struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v,=
 u16 vid)
>> +{
>> +       struct net_port_vlan *pve;
>> +
>> +       /* Must be done either in rcu critical section or with RTNL =
held */
>> +       WARN_ON_ONCE(!rcu_read_lock_held() && !rtnl_is_locked());
>> +
>> +       list_for_each_entry_rcu(pve, &v->vlan_list, list) {
>> +               if (pve->vid =3D=3D vid)
>> +                       return pve;
>> +       }
>> +
>> +       return NULL;
>> +}
>
> This looks expensive - it's O(n) with n =3D number of configured VLAN=
s on a port.
> And this is called for every packet. The bridge already has a hash of=
 VLAN
> structures found by br_vlan_find(). You could add a second bitmap the=
re
> (eg. ingres_ports[]) and check port's bit instead of walking the list=
=2E
> You would use a bit more memory (64 bytes minus the removed list-head=
)
> per configured VLAN but save some cycles in hot path.
>

Technically wouldn't even need another bitmap as an existing membership=
=20
bitmap would cover this case.  I did some profiling and the list is=20
faster for 3 vlans per port.  Hash is faster for more then 3 vlans.

I can easily switch to hash if that is what others think.

-vlad
> Best Regards,
> Micha=B3 Miros=B3aw
>
