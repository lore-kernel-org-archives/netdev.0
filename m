From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6 04/47] nes: do vlan cleanup
Date: Wed, 20 Jul 2011 17:45:06 +0200
Message-ID: <CAHXqBFK6u1JqGjC3Wh8Bn7Y0VjsMOf8WL7eHadLRJafNLX0HXw@mail.gmail.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com> <1311173689-17419-5-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-13
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com, faisal.latif@intel.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:65366 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab1GTPp1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 11:45:27 -0400
Received: by qwk3 with SMTP id 3so185143qwk.19
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 08:45:26 -0700 (PDT)
In-Reply-To: <1311173689-17419-5-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/20 Jiri Pirko <jpirko@redhat.com>:
> - unify vlan and nonvlan rx path
> - kill nesvnic->vlan_grp and nes_netdev_vlan_rx_register
> - allow to turn on/off rx/tx vlan accel via ethtool (set_features)
[...]
> =A0/**
> @@ -1656,7 +1679,7 @@ struct net_device *nes_netdev_init(struct nes_d=
evice *nesdev,
> =A0 =A0 =A0 =A0netdev->ethtool_ops =3D &nes_ethtool_ops;
> =A0 =A0 =A0 =A0netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll=
, 128);
> =A0 =A0 =A0 =A0nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.\=
n");
> - =A0 =A0 =A0 netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_V=
LAN_RX;
> + =A0 =A0 =A0 netdev->features |=3D NETIF_F_HW_VLAN_TX;

Just remove this line - nes_fix_features() is controlling the flag anyw=
ay.

Best Regards,
Micha=F9 Miros=F9aw
