From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] net: Abstract features usage.
Date: Tue, 24 May 2011 13:29:15 -0700
Message-ID: <BANLkTi=F_=Ti=QdDf3-L_hEEwCi9DRR_1Q@mail.gmail.com>
References: <1306263162-2022-1-git-send-email-maheshb@google.com> <BANLkTinTJuKFyf80As81ouePBs=vFvQahg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:25125 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800Ab1EXU3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 16:29:39 -0400
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p4OKTcnw017229
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 13:29:38 -0700
Received: from bwz10 (bwz10.prod.google.com [10.188.26.10])
	by wpaz9.hot.corp.google.com with ESMTP id p4OKTZTN007154
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 13:29:36 -0700
Received: by bwz10 with SMTP id 10so6716885bwz.38
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 13:29:35 -0700 (PDT)
In-Reply-To: <BANLkTinTJuKFyf80As81ouePBs=vFvQahg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 12:37 PM, Micha=C5=82 Miros=C5=82aw <mirqus@gma=
il.com> wrote:
>
> 2011/5/24 Mahesh Bandewar <maheshb@google.com>:
> > Define macros to set/clear/test bits for feature set usage. This wi=
ll eliminate
> > the direct use of these fields and enable future ease in managing t=
hese fields.
> >
> > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> > ---
> > =C2=A0include/linux/netdev_features.h | =C2=A0137 +++++++++++++++++=
++++++++++++++++++++++
> > =C2=A0include/linux/netdevice.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 35 ++=
---------
> > =C2=A02 files changed, 142 insertions(+), 30 deletions(-)
> > =C2=A0create mode 100644 include/linux/netdev_features.h
> >
> > diff --git a/include/linux/netdev_features.h b/include/linux/netdev=
_features.h
> > new file mode 100644
> > index 0000000..97bf8c4
> > --- /dev/null
> > +++ b/include/linux/netdev_features.h
> > @@ -0,0 +1,137 @@
> > +#ifndef =C2=A0 =C2=A0 =C2=A0 =C2=A0_NETDEV_FEATURES_H
> > +#define =C2=A0 =C2=A0 =C2=A0 =C2=A0_NETDEV_FEATURES_H
> > +
> > +/* Forward declarations */
> > +struct net_device;
> > +
> > +typedef =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long *nd_feature_t;
> > +
> > +/* Net device feature bits; if you change something,
> > + * also update netdev_features_strings[] in ethtool.c */
> > +enum netdev_features {
> > + =C2=A0 =C2=A0 =C2=A0 SG_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 /* Scatter/gather IO. */
> [...]
>
> Please split this change (introducing enum + converting NETIF_F_*
> defines to use it). This part is a nice cleanup, but I think the
> bitmap idea is still not worth the trouble until u64 runs out.
>
What will we achieve by this split? May be I'm not getting your point
about split. Do you want to see the cleanup part as a separate patch?
These enums and NETIF_F_* values have to be in sync. The macros that I
have defined are expecting this bit numbers rather than the flag
value.

Whether it is u64 or bitmap, the changes should be limited to this
file. Going forward that can be achieved by
simply changing few lines in these macros / inlines.

Thanks,
--mahesh..

> Best Regards,
> Micha=C5=82 Miros=C5=82aw
