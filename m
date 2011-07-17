From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Sun, 17 Jul 2011 09:30:23 +0200
Message-ID: <20110717073022.GA2089@minipsycho.orion>
References: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44147 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116Ab1GQHbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 03:31:06 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jul 16, 2011 at 04:14:36PM CEST, mirqus@gmail.com wrote:
>2011/7/16 Jiri Pirko <jpirko@redhat.com>:
>> Some devices are not able to enable/disable rx/tw vlan accel separat=
ely.
>> they depend on ndo_vlan_rx_register to know if to enable of disable
>> hw accel. And since ndo_vlan_rx_register is going to die soon,
>> this must be resolved.
>>
>> One solution might be to enable accel on device start every time, ev=
en
>> if there are no vlan up on. But this would change behaviour and migh=
t
>> lead to possible regression (on older devices).
>[...]
>
>Please describe the possible regression. As I see it, there won't be
>any user visible change of behaviour - network code takes care of
>reinserting VLAN tag when necessary. If you think that disabling tag
>stripping is beneficial for cases where no VLANs are configured, it's
>better to do that in netdev_fix_features() for devices which advertise
>NETIF_F_HW_VLAN_RX in hw_features.

Well I just wanted to preserve current behaviour which is that in many
drivers vlan accel is enabled only if some vid is registered upon the
device and it's disabled again when no vid is registered. I can see
no way to do this with current code after removing ndo_vlan_rx_register=
=2E

I expect unexpected problems on old cards when vlan accel would be
enabled all the time, but maybe I'm wrong...

One idea is for device which do not support sepatate rx/tx vlan accel
enabling/disabling they can probably use ndo_fix_features force to=20
enable/disable rx/tx pair together. That would resolve the situation as
well giving user possibility to turn off vlan accel in case of any issu=
es.

>
>Best Regards,
>Micha=C5=82 Miros=C5=82aw
