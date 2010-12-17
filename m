From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] e1000e: convert to stats64
Date: Thu, 16 Dec 2010 19:14:35 -0800
Message-ID: <AANLkTi=y4u1DTtOX9-70CeDGhWGu4bBKK0Y32Js41=bK@mail.gmail.com>
References: <1292358735-32089-1-git-send-email-fleitner@redhat.com>
	<1292362173.2478.6.camel@edumazet-laptop>
	<20101216123131.GA3070@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34273 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab0LQDOg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 22:14:36 -0500
Received: by iyi12 with SMTP id 12so146675iyi.19
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 19:14:35 -0800 (PST)
In-Reply-To: <20101216123131.GA3070@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 04:31, Flavio Leitner <fleitner@redhat.com> wro=
te:
> On Tue, Dec 14, 2010 at 10:29:33PM +0100, Eric Dumazet wrote:
>> Le mardi 14 d=C3=A9cembre 2010 =C3=A0 18:32 -0200, Flavio Leitner a =
=C3=A9crit :
>> > Provides accurate stats at the time user reads them.
>> >
>> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
>> > ---
>> > =C2=A0drivers/net/e1000e/e1000.h =C2=A0 | =C2=A0 =C2=A05 ++-
>> > =C2=A0drivers/net/e1000e/ethtool.c | =C2=A0 27 +++++++++-------
>> > =C2=A0drivers/net/e1000e/netdev.c =C2=A0| =C2=A0 68 ++++++++++++++=
++++++++++-----------------
>> > =C2=A03 files changed, 59 insertions(+), 41 deletions(-)
>> >
>> > diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000=
=2Eh
>> > index fdc67fe..5a5e944 100644
>> > --- a/drivers/net/e1000e/e1000.h
>> > +++ b/drivers/net/e1000e/e1000.h
>> > @@ -363,6 +363,8 @@ struct e1000_adapter {
>> > =C2=A0 =C2=A0 /* structs defined in e1000_hw.h */
>> > =C2=A0 =C2=A0 struct e1000_hw hw;
>> >
>> > + =C2=A0 spinlock_t stats64_lock;
>> > + =C2=A0 struct rtnl_link_stats64 stats64;
>>
>> I am not sure why you add this stats64 in e1000_adapter ?
>>
>> Why isnt it provided by callers (automatic variable, or provided to
>> ndo_get_stats64()). I dont see accumulators, only a full rewrite of =
this
>> structure in e1000e_update_stats() ?
>
> Good point. I have modified the patch to fix that.
> thanks!
>
> From 3487bd7dacd0c23bba315270139dab6e00e5ff02 Mon Sep 17 00:00:00 200=
1
> From: Flavio Leitner <fleitner@redhat.com>
> Date: Thu, 16 Dec 2010 10:26:03 -0200
> Subject: [PATCH] e1000e: convert to stats64
>
> Provides accurate stats at the time user reads them.
>
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> ---
> =C2=A0drivers/net/e1000e/e1000.h =C2=A0 | =C2=A0 =C2=A03 ++
> =C2=A0drivers/net/e1000e/ethtool.c | =C2=A0 25 ++++++++-------
> =C2=A0drivers/net/e1000e/netdev.c =C2=A0| =C2=A0 68 +++++++++++++++++=
++++++++++++++++--------
> =C2=A03 files changed, 70 insertions(+), 26 deletions(-)
>

I have dropped you previous version of the patch and applied v2 to my
tree for review and testing.
Thanks Flavio!


--=20
Cheers,
Jeff
