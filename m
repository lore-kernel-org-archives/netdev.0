From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/2] net: vlan: 802.1ad S-VLAN support
Date: Sat, 12 Nov 2011 10:25:31 +0100
Message-ID: <CAHXqBFJu6Za=PYNytJ0Q+DyqAz_rfs1oobBc97zrbM56qmTcNA@mail.gmail.com>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
 <1320512055-1231037-2-git-send-email-equinox@diac24.net> <20111111.202235.1981500713669985784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: equinox@diac24.net, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:58019 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab1KLJZy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 04:25:54 -0500
Received: by iage36 with SMTP id e36so5017849iag.19
        for <netdev@vger.kernel.org>; Sat, 12 Nov 2011 01:25:53 -0800 (PST)
In-Reply-To: <20111111.202235.1981500713669985784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/12 David Miller <davem@davemloft.net>:
> From: David Lamparter <equinox@diac24.net>
> Date: Sat, =A05 Nov 2011 17:54:14 +0100
>
>> @@ -87,7 +97,8 @@ struct vlan_group {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0nr_vlans;
>> =A0 =A0 =A0 struct hlist_node =A0 =A0 =A0 hlist; =A0/* linked list *=
/
>> - =A0 =A0 struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_S=
PLIT_PARTS];
>> + =A0 =A0 struct net_device **vlan_devices_arrays[VLAN_N_PROTOCOL]
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 [VLAN_GROUP_ARRAY_SPLIT_PARTS];
>> =A0 =A0 =A0 struct rcu_head =A0 =A0 =A0 =A0 rcu;
>> =A0};
> This is a terrible waste of memory. =A0You're now using 5 times as mu=
ch space,
> the vast majority of which will be entirely unused.
>
> I don't even think it's semantically correct, all these alias QinQ pr=
otocol
> values don't provide completely new VLAN_ID name spaces at all. =A0So=
 this
> layout doesn't even make any sense, you're allowing for something tha=
t isn't
> even allowed.

While I agree about the memory usage argument, I also like the
separation idea as is. If you want VLANs encapsulated in other
protocols to alias, then you can still do it by attaching them to
properly configured bond or bridge.

Best Regards,
Micha=B3 Miros=B3aw
