From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: Abstract features usage.
Date: Tue, 24 May 2011 16:11:38 -0700
Message-ID: <20110524161138.55aed6b1@nehalam>
References: <1306263162-2022-1-git-send-email-maheshb@google.com>
	<20110524142928.105d66ef@nehalam>
	<BANLkTin48HKVRn6kG8SCZNfhyWVVhkBArg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53233 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754804Ab1EXXLl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 19:11:41 -0400
In-Reply-To: <BANLkTin48HKVRn6kG8SCZNfhyWVVhkBArg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 May 2011 16:04:20 -0700
Mahesh Bandewar <maheshb@google.com> wrote:

> On Tue, May 24, 2011 at 2:29 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > On Tue, 24 May 2011 11:52:42 -0700
> > Mahesh Bandewar <maheshb@google.com> wrote:
> >
> >> Define macros to set/clear/test bits for feature set usage. This w=
ill eliminate
> >> the direct use of these fields and enable future ease in managing =
these fields.
> >>
> >> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> >> ---
> >> =C2=A0include/linux/netdev_features.h | =C2=A0137 ++++++++++++++++=
+++++++++++++++++++++++
> >> =C2=A0include/linux/netdevice.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 35 +=
+---------
> >> =C2=A02 files changed, 142 insertions(+), 30 deletions(-)
> >> =C2=A0create mode 100644 include/linux/netdev_features.h
> >>
> >> diff --git a/include/linux/netdev_features.h b/include/linux/netde=
v_features.h
> >> new file mode 100644
> >> index 0000000..97bf8c4
> >> --- /dev/null
> >> +++ b/include/linux/netdev_features.h
> >> @@ -0,0 +1,137 @@
> >> +#ifndef =C2=A0 =C2=A0 =C2=A0_NETDEV_FEATURES_H
> >> +#define =C2=A0 =C2=A0 =C2=A0_NETDEV_FEATURES_H
> >> +
> >> +/* Forward declarations */
> >> +struct net_device;
> >> +
> >> +typedef =C2=A0 =C2=A0 =C2=A0unsigned long *nd_feature_t
> >
> > typedef'ing a pointer is strongly discouraged by kernel coding styl=
e.
> > You need to use another way such as open coding it.
> >
> The idea here is to have a typedef that we can use to avoid future
> changes all over the code if we decide to change the way feature bits
> are stored. So if this is bitmap it will be defined as "unsigned long
> *" and if it were to be u64 then it's typedef-ed as "u64". So in one
> case it's a pointer and in other case it's not! Now how do we handle
> both these cases?

It is okay to add a typedef for a fixed width type.=20
Just not adding the indirection
because it leads to confusion.

Read "Chapter 5: Typedefs" in Documentation/CodingStyle



--=20
