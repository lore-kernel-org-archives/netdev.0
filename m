From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC net-next PATCH 4/4] ixgbe: Add support for new ethtool settings
Date: Thu, 28 Jul 2011 13:54:16 +0200
Message-ID: <CAHXqBFJ30LLV=dgWuSK73rhxYLt5xoVFVwHdU3cWFmr_Yxs5pg@mail.gmail.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com> <20110727221804.8435.97686.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:45424 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244Ab1G1Lyh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 07:54:37 -0400
Received: by qyk29 with SMTP id 29so2687912qyk.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 04:54:36 -0700 (PDT)
In-Reply-To: <20110727221804.8435.97686.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/28 Greg Rose <gregory.v.rose@intel.com>:
> Adds ixgbe driver support for new ethtool settings for SR-IOV re-init=
,
> number of VM queues and anti-spoofing ON/OFF switch.
[...]
> +static int ixgbe_reinit_sriov(struct net_device *netdev, int new_vfs=
)
> +{
[...]
> +       if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
> +               adapter->flags &=3D ~(IXGBE_FLAG_RSS_ENABLED |
> +                                   IXGBE_FLAG_DCB_ENABLED);
> +               netdev->features &=3D ~NETIF_F_RXHASH;
> +       } else {
> +               adapter->flags |=3D IXGBE_FLAG_RSS_ENABLED;
> +               netdev->features |=3D NETIF_F_RXHASH;
> +       }

Please use ndo_fix_features/ndo_set_features callbacks for this.

Best Regards,
Micha=B3 Miros=B3aw
