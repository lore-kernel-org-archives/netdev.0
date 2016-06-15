From: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Subject: Re: [PATCH] mac80211_hwsim: Allow wmediumd to attach to radios
 created in its netns
Date: Wed, 15 Jun 2016 14:37:13 +0200
Message-ID: <1465994233.3807.18.camel@strongswan.org>
References: <1463214884-5983-1-git-send-email-martin@strongswan.org>
	 <1465978217.2994.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465978217.2994.4.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>=20
> > =C2=A0printk(KERN_INFO "mac80211_hwsim: wmediumd released netlink"
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 " socket, switching to perfect channel =
medium\n");

> I wonder if we can do something better about them? Or perhaps if we
> should remove them, so other namespaces won't mess up the kernel log

This is in fact not very nice, but not specific to hwsim. Any namespace
can mess up the kernel log from different (networking) subsystems. This
has been discussed some time ago [1], but AFAIK there is no real
solution so far.

=46or this patch I think we have the following options:
 * Keep the printk() messages as proposed
 * Remove those callable from non-initial namespaces completely
 * Suppress them when called from non-initial namespaces
 * Include the associated "netgroup" in the message

I personally would prefer the first option, as this problem is not
specific to hwsim or mac80211, but many subsystems. So we certainly can
add some work-around, but there is not much to gain if other modules
don't.

Regards
Martin


[1]https://lwn.net/Articles/527342/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
