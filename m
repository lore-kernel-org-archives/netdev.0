From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
 data size
Date: Tue, 10 May 2011 04:43:33 +0200
Message-ID: <1304995413.3050.19.camel@edumazet-laptop>
References: <20110509222629.8689.77365.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	davem@davemloft.net
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35890 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab1EJCni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 22:43:38 -0400
Received: by wwa36 with SMTP id 36so6382048wwa.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 19:43:37 -0700 (PDT)
In-Reply-To: <20110509222629.8689.77365.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 15:26 -0700, Greg Rose a =C3=A9crit :
> The message size allocated for rtnl info dumps was limited to a singl=
e
> page.  This is not enough for additional interface info available wit=
h
> devices that support SR-IOV.  Calculate the amount of data required s=
o
> the dump can allocate enough data to satisfy the request.
>=20
> V2 of this patch adds a new argument to the rtnl_register service tha=
t
> allows for a new method to calculate the amount of data required to
> complete the info dump request.  So far the method is only implemente=
d
> for the RTM_GETLINK slot.
>=20
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>

> =20
> +static u16 rtnl_calcit(struct sk_buff *skb)
> +{
> +	struct net *net =3D sock_net(skb->sk);
> +	int h;
> +	int idx =3D 0, s_idx;
> +	struct net_device *dev;
> +	struct hlist_head *head;
> +	struct hlist_node *node;
> +	u16 alloc_size =3D 0;
> +
> +	for (h =3D 0; h < NETDEV_HASHENTRIES; h++, s_idx =3D 0) {
> +		idx =3D 0;
> +		head =3D &net->dev_index_head[h];
> +		hlist_for_each_entry(dev, node, head, index_hlist) {
> +			if (idx < s_idx) {
> +				idx++;
> +				continue;
> +			}
> +			alloc_size =3D (u16)if_nlmsg_size(dev);
> +			break;
> +		}
> +	}
> +
> +	return alloc_size;
> +}
> +


Sorry this wont scale. Some machines have thousand of devices.

Just make an upper approximation, you dont need an exact one ;)



