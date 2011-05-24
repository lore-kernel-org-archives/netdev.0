From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] net: Abstract features usage.
Date: Tue, 24 May 2011 23:49:19 +0200
Message-ID: <BANLkTinpNJz-6y1hvw6uzDJsixHHLEuA-w@mail.gmail.com>
References: <1306263162-2022-1-git-send-email-maheshb@google.com>
 <BANLkTinTJuKFyf80As81ouePBs=vFvQahg@mail.gmail.com> <BANLkTi=F_=Ti=QdDf3-L_hEEwCi9DRR_1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:41561 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754418Ab1EXVtk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 17:49:40 -0400
Received: by qwk3 with SMTP id 3so3602232qwk.19
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 14:49:39 -0700 (PDT)
In-Reply-To: <BANLkTi=F_=Ti=QdDf3-L_hEEwCi9DRR_1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 24 maja 2011 22:29 u=BFytkownik Mahesh Bandewar
<maheshb@google.com> napisa=B3:
> On Tue, May 24, 2011 at 12:37 PM, Micha=B3 Miros=B3aw <mirqus@gmail.c=
om> wrote:
>>
>> 2011/5/24 Mahesh Bandewar <maheshb@google.com>:
>> > Define macros to set/clear/test bits for feature set usage. This w=
ill eliminate
>> > the direct use of these fields and enable future ease in managing =
these fields.
>> >
>> > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> > ---
>> > =A0include/linux/netdev_features.h | =A0137 ++++++++++++++++++++++=
+++++++++++++++++
>> > =A0include/linux/netdevice.h =A0 =A0 =A0 | =A0 35 ++---------
>> > =A02 files changed, 142 insertions(+), 30 deletions(-)
>> > =A0create mode 100644 include/linux/netdev_features.h
>> >
>> > diff --git a/include/linux/netdev_features.h b/include/linux/netde=
v_features.h
>> > new file mode 100644
>> > index 0000000..97bf8c4
>> > --- /dev/null
>> > +++ b/include/linux/netdev_features.h
>> > @@ -0,0 +1,137 @@
>> > +#ifndef =A0 =A0 =A0 =A0_NETDEV_FEATURES_H
>> > +#define =A0 =A0 =A0 =A0_NETDEV_FEATURES_H
>> > +
>> > +/* Forward declarations */
>> > +struct net_device;
>> > +
>> > +typedef =A0 =A0 =A0 =A0unsigned long *nd_feature_t;
>> > +
>> > +/* Net device feature bits; if you change something,
>> > + * also update netdev_features_strings[] in ethtool.c */
>> > +enum netdev_features {
>> > + =A0 =A0 =A0 SG_BIT, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Scatter/g=
ather IO. */
>> [...]
>>
>> Please split this change (introducing enum + converting NETIF_F_*
>> defines to use it). This part is a nice cleanup, but I think the
>> bitmap idea is still not worth the trouble until u64 runs out.
> What will we achieve by this split? May be I'm not getting your point
> about split. Do you want to see the cleanup part as a separate patch?
> These enums and NETIF_F_* values have to be in sync.

Exactly. You already did the cleanup (defining enum and NETIF_F_*
#defines), so just split it into separate patch. This is a
prerequisite to any change to the type holding features from u32 to
either u64 or bitmap. And this will separate the cleanup from your
proposed idea.

> The macros that I have defined are expecting this bit numbers rather
> than the flag value.
> Whether it is u64 or bitmap, the changes should be limited to this
> file. Going forward that can be achieved by
> simply changing few lines in these macros / inlines.

One thing I don't like in this implementation is that it leaves old
fields around - so you'll have two code templates in the kernel doing
the same thing (unless you fix all users, but then you won't need old
fields anyway).

Best Regards,
Micha=B3 Miros=B3aw
