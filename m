From: Alessandro Salvatori <sandr8@gmail.com>
Subject: Re: [Pv-drivers] vmxnet3 driver broken since 3.0?
Date: Mon, 12 Dec 2011 15:29:27 -0800
Message-ID: <CAJeBh4unodegb1e-Og+kY9AC-+OiHE3Kq_6N=+TZ679CBoSu1w@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B9150914BA@nsmail.netscout.com>
 <CAAsGZS7QL1vQwoq7k2RX_LWeqgE4x5+00NSrRYbCu8vQoGh1Hg@mail.gmail.com> <20111212174244.GA31005@dtor-ws.eng.vmware.com>
Reply-To: sandr8@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chetan loke <loke.chetan@gmail.com>, pv-drivers@vmware.com,
	zbiggy@o2.pl, netdev <netdev@vger.kernel.org>
To: Dmitry Torokhov <dtor@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:56306 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668Ab1LLX36 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 18:29:58 -0500
Received: by qcqz2 with SMTP id z2so4075277qcq.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 15:29:58 -0800 (PST)
In-Reply-To: <20111212174244.GA31005@dtor-ws.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

can you please make sure this also goes into linux-stable for 3.0.x and=
 3.1.x?

thanks!
-Alessandro-
=A0Here i am, A young man,
=A0A crashing computer program,
=A0Here is a pen, write out my name...

(from: The Servant - Orchestra)



On Mon, Dec 12, 2011 at 09:42, Dmitry Torokhov <dtor@vmware.com> wrote:
> On Mon, Dec 12, 2011 at 12:09:33PM -0500, chetan loke wrote:
>> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kerne=
l.org] On Behalf Of Alessandro Salvatori
>> > Sent: December 12, 2011 2:55 AM
>> > To: Zbigniew Luszpinski
>> > Cc: netdev@vger.kernel.org
>> > Subject: Re: vmxnet3 driver broken since 3.0?
>> >
>> > I guess this is the change that was introduced in 3.0 and that bre=
aks vmxnet3:
>> >
>> > commit 55513fb4281464e97aa1ff2b9c906ca5aed917c5
>> > Author: Tom Herbert <therbert@google.com>
>> > Date: =A0 Mon Oct 18 17:55:58 2010 +0000
>> >
>> > =A0 =A0net: fail alloc_netdev_mq if queue count < 1
>> >
>> > =A0 =A0In alloc_netdev_mq fail if requested queue_count < 1.
>> >
>> > =A0 =A0Signed-off-by: Tom Herbert <therbert@google.com>
>> > =A0 =A0Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>> > =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>> >
>> > diff --git a/net/core/dev.c b/net/core/dev.c
>> > index 04972a4..f44d29a 100644
>> > --- a/net/core/dev.c
>> > +++ b/net/core/dev.c
>> > @@ -5511,6 +5511,12 @@ struct net_device *alloc_netdev_mq(int
>> > sizeof_priv, const char *name,
>> >
>> > =A0 =A0 =A0 =A0BUG_ON(strlen(name) >=3D sizeof(dev->name));
>> >
>> > + =A0 =A0 =A0 if (queue_count < 1) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("alloc_netdev: Unable to allo=
cate device "
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"with zero queues.\n"=
);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> > + =A0 =A0 =A0 }
>> > +
>> > =A0 =A0 =A0 =A0alloc_size =3D sizeof(struct net_device);
>> > =A0 =A0 =A0 =A0if (sizeof_priv) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* ensure 32-byte alignment of priv=
ate area */
>> >
>> > thanks!
>> > -Alessandro-
>>
>
> Hmm, apparently patch from https://lkml.org/lkml/2011/11/16/387 is no=
t
> in mailine yet... I am going to forward it to Linus/Andrew.
>
> Thanks,
> Dmitry
>
