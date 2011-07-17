From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Sun, 17 Jul 2011 21:44:22 +0200
Message-ID: <20110717194421.GA2153@minipsycho>
References: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com>
 <20110717073022.GA2089@minipsycho.orion>
 <CAHXqBFL1s30DxxHk-1wEy1q48LvgbO+w4zXkOm0sAU61XONoVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754107Ab1GQToc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 15:44:32 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBFL1s30DxxHk-1wEy1q48LvgbO+w4zXkOm0sAU61XONoVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 17, 2011 at 10:36:04AM CEST, mirqus@gmail.com wrote:
>W dniu 17 lipca 2011 09:30 u=C5=BCytkownik Jiri Pirko <jpirko@redhat.c=
om> napisa=C5=82:
>> Sat, Jul 16, 2011 at 04:14:36PM CEST, mirqus@gmail.com wrote:
>>>2011/7/16 Jiri Pirko <jpirko@redhat.com>:
>>>> Some devices are not able to enable/disable rx/tw vlan accel separ=
ately.
>>>> they depend on ndo_vlan_rx_register to know if to enable of disabl=
e
>>>> hw accel. And since ndo_vlan_rx_register is going to die soon,
>>>> this must be resolved.
>>>>
>>>> One solution might be to enable accel on device start every time, =
even
>>>> if there are no vlan up on. But this would change behaviour and mi=
ght
>>>> lead to possible regression (on older devices).
>>>[...]
>>>
>>>Please describe the possible regression. As I see it, there won't be
>>>any user visible change of behaviour - network code takes care of
>>>reinserting VLAN tag when necessary. If you think that disabling tag
>>>stripping is beneficial for cases where no VLANs are configured, it'=
s
>>>better to do that in netdev_fix_features() for devices which adverti=
se
>>>NETIF_F_HW_VLAN_RX in hw_features.
>>
>> Well I just wanted to preserve current behaviour which is that in ma=
ny
>> drivers vlan accel is enabled only if some vid is registered upon th=
e
>> device and it's disabled again when no vid is registered. I can see
>> no way to do this with current code after removing ndo_vlan_rx_regis=
ter.
>>
>> I expect unexpected
>
>:-D
>
>> ... problems on old cards when vlan accel would be
>> enabled all the time, but maybe I'm wrong...
>
>Device has no way of knowing how the system uses VLAN tags, stripped
>or not. Any problems would be driver problems and since you're making
>it all use generic code, bugs will hit all drivers simultaneously or
>(preferably) won't happen at all.
>
>> One idea is for device which do not support sepatate rx/tx vlan acce=
l
>> enabling/disabling they can probably use ndo_fix_features force to
>> enable/disable rx/tx pair together. That would resolve the situation=
 as
>> well giving user possibility to turn off vlan accel in case of any i=
ssues.
>
>That is exactly the idea behind ndo_fix_features.

In netdev_fix_features add check if either one of NETIF_F_HW_VLAN_TX or
NETIF_F_HW_VLAN_RX is set and in that case set the other one. Of course
this would be done only for devices what do not support separate rx/tx
vlan on/off. But how to distinguish? NETIF_F_HW_VLAN_BOTH feature flag?

Thanks.

Jirka

>
>Best Regards,
>Micha=C5=82 Miros=C5=82aw
