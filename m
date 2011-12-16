From: Dave Taht <dave.taht@gmail.com>
Subject: Re: skb->priority usage in wireless frame classification
Date: Fri, 16 Dec 2011 10:35:51 +0100
Message-ID: <CAA93jw4-OEbiSpQM+SJn7R0uAe0o-nw0kwgvjVkL4w4AeWQtjQ@mail.gmail.com>
References: <CAGXE3d_ouo4KzQA0-ysLz_RwcqoTc5Sg4V6BZZJP0TJewzNOxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>
To: Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:57747 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462Ab1LPJfw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 04:35:52 -0500
In-Reply-To: <CAGXE3d_ouo4KzQA0-ysLz_RwcqoTc5Sg4V6BZZJP0TJewzNOxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 16, 2011 at 9:45 AM, Helmut Schaa
<helmut.schaa@googlemail.com> wrote:
> [Adding netdev]
>
> Maybe someone from the netdev people can shed some light on this.
> We've got the following code in net/wireless/util.c for frame classif=
ication
> (cfg80211_classify8021d):
>
> /* skb->priority values from 256->263 are magic values to
> * directly indicate a specific 802.1d priority. =A0This is used
> * to allow 802.1d priority to be passed directly in from VLAN
> * tags, etc.
> */
> if (skb->priority >=3D 256 && skb->priority <=3D 263)
> =A0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return skb->priority - 256;
>
> I was just thinking about making use of this for some internal mac802=
11
> QoS handling. But is this code still valid? At least I haven't found =
anything
> in the 802.1q code :(

I made use of the above 'feature' while prototyping some Diffserv work
with iptables. I have no idea if there are users of this obscure
overloading of priority in userspace....

The vlan code at least used to do something like this:

net/8021q/vlan.h: *	@vlan_qos: vlan priority: (skb->priority << 13) & 0=
xE000

But I don't see that at first glance in the current code... this part
is functionally the same...

vlan_netlink.c:				m.to   =3D (pm->vlan_qos >> 13) & 0x7;
vlanproc.c:				   mp->priority, ((mp->vlan_qos >> 13) & 0x7));

Assuming that somewhere else was an assignment from priority to this...

> Thanks,
> Helmut
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
