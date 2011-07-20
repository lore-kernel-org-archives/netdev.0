From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6 04/47] nes: do vlan cleanup
Date: Wed, 20 Jul 2011 18:01:09 +0200
Message-ID: <CAHXqBFJ3ERvHTcJcJLOGSGeYGbnE9XaRu7Dm_dRjAmR4PYq+VA@mail.gmail.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
 <1311173689-17419-5-git-send-email-jpirko@redhat.com> <CAHXqBFK6u1JqGjC3Wh8Bn7Y0VjsMOf8WL7eHadLRJafNLX0HXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com, faisal.latif@intel.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:43574 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584Ab1GTQB3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 12:01:29 -0400
Received: by qyk29 with SMTP id 29so2750508qyk.19
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 09:01:29 -0700 (PDT)
In-Reply-To: <CAHXqBFK6u1JqGjC3Wh8Bn7Y0VjsMOf8WL7eHadLRJafNLX0HXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 20 lipca 2011 17:45 u=BFytkownik Micha=B3 Miros=B3aw
<mirqus@gmail.com> napisa=B3:
> 2011/7/20 Jiri Pirko <jpirko@redhat.com>:
>> - unify vlan and nonvlan rx path
>> - kill nesvnic->vlan_grp and nes_netdev_vlan_rx_register
>> - allow to turn on/off rx/tx vlan accel via ethtool (set_features)
> [...]
>> =A0/**
>> @@ -1656,7 +1679,7 @@ struct net_device *nes_netdev_init(struct nes_=
device *nesdev,
>> =A0 =A0 =A0 =A0netdev->ethtool_ops =3D &nes_ethtool_ops;
>> =A0 =A0 =A0 =A0netif_napi_add(netdev, &nesvnic->napi, nes_netdev_pol=
l, 128);
>> =A0 =A0 =A0 =A0nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.=
\n");
>> - =A0 =A0 =A0 netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_=
VLAN_RX;
>> + =A0 =A0 =A0 netdev->features |=3D NETIF_F_HW_VLAN_TX;
> Just remove this line - nes_fix_features() is controlling the flag an=
yway.

=46orget it - it's good.

I need to think about calling ndo_set_features callback at end of
register_netdev() so the drivers won't need to duplicate the
call/configuration in their ndo_init.

Best Regards,
Micha=B3 Miros=B3aw
