From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 04/47] nes: do vlan cleanup
Date: Wed, 20 Jul 2011 21:00:30 +0200
Message-ID: <20110720190027.GA2688@minipsycho.redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
 <1311173689-17419-5-git-send-email-jpirko@redhat.com>
 <CAHXqBFK6u1JqGjC3Wh8Bn7Y0VjsMOf8WL7eHadLRJafNLX0HXw@mail.gmail.com>
 <CAHXqBFJ3ERvHTcJcJLOGSGeYGbnE9XaRu7Dm_dRjAmR4PYq+VA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com, faisal.latif@intel.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21493 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178Ab1GTTAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 15:00:40 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBFJ3ERvHTcJcJLOGSGeYGbnE9XaRu7Dm_dRjAmR4PYq+VA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jul 20, 2011 at 06:01:09PM CEST, mirqus@gmail.com wrote:
>W dniu 20 lipca 2011 17:45 u=C5=BCytkownik Micha=C5=82 Miros=C5=82aw
><mirqus@gmail.com> napisa=C5=82:
>> 2011/7/20 Jiri Pirko <jpirko@redhat.com>:
>>> - unify vlan and nonvlan rx path
>>> - kill nesvnic->vlan_grp and nes_netdev_vlan_rx_register
>>> - allow to turn on/off rx/tx vlan accel via ethtool (set_features)
>> [...]
>>> =C2=A0/**
>>> @@ -1656,7 +1679,7 @@ struct net_device *nes_netdev_init(struct nes=
_device *nesdev,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev->ethtool_ops =3D &nes_ethtool_ops=
;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_napi_add(netdev, &nesvnic->napi, n=
es_netdev_poll, 128);
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0nes_debug(NES_DBG_INIT, "Enabling VLAN I=
nsert/Delete.\n");
>>> - =C2=A0 =C2=A0 =C2=A0 netdev->features |=3D NETIF_F_HW_VLAN_TX | N=
ETIF_F_HW_VLAN_RX;
>>> + =C2=A0 =C2=A0 =C2=A0 netdev->features |=3D NETIF_F_HW_VLAN_TX;
>> Just remove this line - nes_fix_features() is controlling the flag a=
nyway.
>
>Forget it - it's good.
>
>I need to think about calling ndo_set_features callback at end of
>register_netdev() so the drivers won't need to duplicate the
>call/configuration in their ndo_init.

Yep, this came up to my thinking as well.

>
>Best Regards,
>Micha=C5=82 Miros=C5=82aw
