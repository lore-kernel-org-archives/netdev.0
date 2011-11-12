From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/2] net: vlan: 802.1ad S-VLAN support
Date: Sat, 12 Nov 2011 17:06:40 +0100
Message-ID: <CAHXqBF+vKX9k7QTsO4rhGmzMHVWBEkxMvXwnvYD64O+Dbka2=Q@mail.gmail.com>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
 <1320512055-1231037-2-git-send-email-equinox@diac24.net> <20111111.202235.1981500713669985784.davem@davemloft.net>
 <20111112141429.GA41984@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:35639 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395Ab1KLQHC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 11:07:02 -0500
Received: by iage36 with SMTP id e36so5277560iag.19
        for <netdev@vger.kernel.org>; Sat, 12 Nov 2011 08:07:01 -0800 (PST)
In-Reply-To: <20111112141429.GA41984@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/12 David Lamparter <equinox@diac24.net>:
> On Fri, Nov 11, 2011 at 08:22:35PM -0500, David Miller wrote:
>> > @@ -87,7 +97,8 @@ struct vlan_group {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 */
>> > =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0nr_vlans;
>> > =A0 =A0 struct hlist_node =A0 =A0 =A0 hlist; =A0/* linked list */
>> > - =A0 struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPL=
IT_PARTS];
>> > + =A0 struct net_device **vlan_devices_arrays[VLAN_N_PROTOCOL]
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 [VLAN_GROUP_ARRAY_SPLIT_PARTS];
>> > =A0 =A0 struct rcu_head =A0 =A0 =A0 =A0 rcu;
>> > =A0};
>>
>> This is a terrible waste of memory. =A0You're now using 5 times as m=
uch space,
>> the vast majority of which will be entirely unused.
>
> VLAN_GROUP_ARRAY_SPLIT_PARTS is 8; so the memory consumption of this =
was
> previously 8 * ptr =3D 64 bytes and is now 5 * 8 * ptr =3D 320 bytes.=
 I thought
> those extra 256 bytes per VLAN-carrying master device are worth the
> simplicity, especially since this saves me impacts on 802.1Q C-VLAN
> lookup performance elsewhere.

I misread this as a table of all VLANs. It doesn't look that terrible
now compared to old scheme. In the case when you have only a handful
of VLANs configured you waste a 4kB per VLAN (but that's how it is
done already).

Best Regards,
Micha=B3 Miros=B3aw
