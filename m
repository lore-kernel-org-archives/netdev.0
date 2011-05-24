From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] net: Abstract features usage.
Date: Tue, 24 May 2011 16:11:03 -0700
Message-ID: <BANLkTikzQOQDDpeaiQkZR7OR-pBPaVFz3A@mail.gmail.com>
References: <1306263162-2022-1-git-send-email-maheshb@google.com>
 <BANLkTinTJuKFyf80As81ouePBs=vFvQahg@mail.gmail.com> <BANLkTi=F_=Ti=QdDf3-L_hEEwCi9DRR_1Q@mail.gmail.com>
 <BANLkTinpNJz-6y1hvw6uzDJsixHHLEuA-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:59538 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174Ab1EXXL5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 19:11:57 -0400
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p4ONBuGE020506
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 16:11:56 -0700
Received: from bwz5 (bwz5.prod.google.com [10.188.26.5])
	by kpbe13.cbf.corp.google.com with ESMTP id p4ONBrbx024249
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 16:11:54 -0700
Received: by bwz5 with SMTP id 5so7537942bwz.20
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 16:11:53 -0700 (PDT)
In-Reply-To: <BANLkTinpNJz-6y1hvw6uzDJsixHHLEuA-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 2:49 PM, Micha=B3 Miros=B3aw <mirqus@gmail.com>=
 wrote:
> W dniu 24 maja 2011 22:29 u=BFytkownik Mahesh Bandewar
> <maheshb@google.com> napisa=B3:
>> On Tue, May 24, 2011 at 12:37 PM, Micha=B3 Miros=B3aw <mirqus@gmail.=
com> wrote:
>>>
>>> 2011/5/24 Mahesh Bandewar <maheshb@google.com>:
>>> > Define macros to set/clear/test bits for feature set usage. This =
will eliminate
>>> > the direct use of these fields and enable future ease in managing=
 these fields.
>>> >
>>> > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>>> > ---
>>> > =A0include/linux/netdev_features.h | =A0137 +++++++++++++++++++++=
++++++++++++++++++
>>> > =A0include/linux/netdevice.h =A0 =A0 =A0 | =A0 35 ++---------
>>> > =A02 files changed, 142 insertions(+), 30 deletions(-)
>>> > =A0create mode 100644 include/linux/netdev_features.h
>>> >
>>> > diff --git a/include/linux/netdev_features.h b/include/linux/netd=
ev_features.h
>>> > new file mode 100644
>>> > index 0000000..97bf8c4
>>> > --- /dev/null
>>> > +++ b/include/linux/netdev_features.h
>>> > @@ -0,0 +1,137 @@
>>> > +#ifndef =A0 =A0 =A0 =A0_NETDEV_FEATURES_H
>>> > +#define =A0 =A0 =A0 =A0_NETDEV_FEATURES_H
>>> > +
>>> > +/* Forward declarations */
>>> > +struct net_device;
>>> > +
>>> > +typedef =A0 =A0 =A0 =A0unsigned long *nd_feature_t;
>>> > +
>>> > +/* Net device feature bits; if you change something,
>>> > + * also update netdev_features_strings[] in ethtool.c */
>>> > +enum netdev_features {
>>> > + =A0 =A0 =A0 SG_BIT, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Scatter/=
gather IO. */
>>> [...]
>>>
>>> Please split this change (introducing enum + converting NETIF_F_*
>>> defines to use it). This part is a nice cleanup, but I think the
>>> bitmap idea is still not worth the trouble until u64 runs out.
>> What will we achieve by this split? May be I'm not getting your poin=
t
>> about split. Do you want to see the cleanup part as a separate patch=
?
>> These enums and NETIF_F_* values have to be in sync.
>
> Exactly. You already did the cleanup (defining enum and NETIF_F_*
> #defines), so just split it into separate patch. This is a
> prerequisite to any change to the type holding features from u32 to
> either u64 or bitmap. And this will separate the cleanup from your
> proposed idea.
>
Alright, will split the change into two pieces.

>> The macros that I have defined are expecting this bit numbers rather
>> than the flag value.
>> Whether it is u64 or bitmap, the changes should be limited to this
>> file. Going forward that can be achieved by
>> simply changing few lines in these macros / inlines.
>
> One thing I don't like in this implementation is that it leaves old
> fields around - so you'll have two code templates in the kernel doing
> the same thing (unless you fix all users, but then you won't need old
> fields anyway).
>
The older fields give us longer time frame to make these changes where
ever necessary. Also enable us to make these changes in stages. Once
all the changes are in place, the older-fields along with the code
instrumentation will be removed. So yes, this file / macros / inlines
will be touched at the end of the completion of the last phase.

Thanks,
--mahesh..

> Best Regards,
> Micha=B3 Miros=B3aw
>
