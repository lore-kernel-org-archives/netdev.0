From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Sat, 16 Jul 2011 16:14:36 +0200
Message-ID: <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com>
References: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:62679 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755286Ab1GPOO5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2011 10:14:57 -0400
Received: by qwk3 with SMTP id 3so961843qwk.19
        for <netdev@vger.kernel.org>; Sat, 16 Jul 2011 07:14:56 -0700 (PDT)
In-Reply-To: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/16 Jiri Pirko <jpirko@redhat.com>:
> Some devices are not able to enable/disable rx/tw vlan accel separate=
ly.
> they depend on ndo_vlan_rx_register to know if to enable of disable
> hw accel. And since ndo_vlan_rx_register is going to die soon,
> this must be resolved.
>
> One solution might be to enable accel on device start every time, eve=
n
> if there are no vlan up on. But this would change behaviour and might
> lead to possible regression (on older devices).
[...]

Please describe the possible regression. As I see it, there won't be
any user visible change of behaviour - network code takes care of
reinserting VLAN tag when necessary. If you think that disabling tag
stripping is beneficial for cases where no VLANs are configured, it's
better to do that in netdev_fix_features() for devices which advertise
NETIF_F_HW_VLAN_RX in hw_features.

Best Regards,
Micha=C5=82 Miros=C5=82aw
