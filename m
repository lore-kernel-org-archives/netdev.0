From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Sun, 17 Jul 2011 10:36:04 +0200
Message-ID: <CAHXqBFL1s30DxxHk-1wEy1q48LvgbO+w4zXkOm0sAU61XONoVw@mail.gmail.com>
References: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com> <20110717073022.GA2089@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:34306 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab1GQIgZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 04:36:25 -0400
Received: by qwk3 with SMTP id 3so1121473qwk.19
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 01:36:24 -0700 (PDT)
In-Reply-To: <20110717073022.GA2089@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 17 lipca 2011 09:30 u=BFytkownik Jiri Pirko <jpirko@redhat.com> =
napisa=B3:
> Sat, Jul 16, 2011 at 04:14:36PM CEST, mirqus@gmail.com wrote:
>>2011/7/16 Jiri Pirko <jpirko@redhat.com>:
>>> Some devices are not able to enable/disable rx/tw vlan accel separa=
tely.
>>> they depend on ndo_vlan_rx_register to know if to enable of disable
>>> hw accel. And since ndo_vlan_rx_register is going to die soon,
>>> this must be resolved.
>>>
>>> One solution might be to enable accel on device start every time, e=
ven
>>> if there are no vlan up on. But this would change behaviour and mig=
ht
>>> lead to possible regression (on older devices).
>>[...]
>>
>>Please describe the possible regression. As I see it, there won't be
>>any user visible change of behaviour - network code takes care of
>>reinserting VLAN tag when necessary. If you think that disabling tag
>>stripping is beneficial for cases where no VLANs are configured, it's
>>better to do that in netdev_fix_features() for devices which advertis=
e
>>NETIF_F_HW_VLAN_RX in hw_features.
>
> Well I just wanted to preserve current behaviour which is that in man=
y
> drivers vlan accel is enabled only if some vid is registered upon the
> device and it's disabled again when no vid is registered. I can see
> no way to do this with current code after removing ndo_vlan_rx_regist=
er.
>
> I expect unexpected

:-D

> ... problems on old cards when vlan accel would be
> enabled all the time, but maybe I'm wrong...

Device has no way of knowing how the system uses VLAN tags, stripped
or not. Any problems would be driver problems and since you're making
it all use generic code, bugs will hit all drivers simultaneously or
(preferably) won't happen at all.

> One idea is for device which do not support sepatate rx/tx vlan accel
> enabling/disabling they can probably use ndo_fix_features force to
> enable/disable rx/tx pair together. That would resolve the situation =
as
> well giving user possibility to turn off vlan accel in case of any is=
sues.

That is exactly the idea behind ndo_fix_features.

Best Regards,
Micha=B3 Miros=B3aw
