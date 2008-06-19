From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: Re: [PATCH] fs_enet: restore promiscuous and multicast settings in restart()
Date: Thu, 19 Jun 2008 23:41:33 +0400
Message-ID: <8496f91a0806191241v14c8a054s93f5a352bff68c62@mail.gmail.com>
References: <200806181707.17739.laurentp@cse-semaphore.com>
	 <8496f91a0806181145w62d57a7fua767c8036f2261aa@mail.gmail.com>
	 <20080619222042.2910e284@vitb.ru.mvista.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Laurent Pinchart" <laurentp@cse-semaphore.com>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	pantelis.antoniou@gmail.com
To: "Vitaly Bordug" <vbordug@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:16429 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbYFSTle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 15:41:34 -0400
Received: by yx-out-2324.google.com with SMTP id 31so207226yxl.1
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 12:41:33 -0700 (PDT)
In-Reply-To: <20080619222042.2910e284@vitb.ru.mvista.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, please. =)

2008/6/19 Vitaly Bordug <vbordug@ru.mvista.com>:
> On Wed, 18 Jun 2008 22:45:57 +0400
> "Matvejchikov Ilya" <matvejchikov@gmail.com> wrote:
>
>> I'm glad that you have corrected it. Half a year ago I pointed out
>> that there was such a mistake:
>> http://patchwork.ozlabs.org/linuxppc/patch?id=10700
>>
> You've used -embedded ML, and patch wasn't noticed... I can add your S-O-B line if that will make you fill better :)
>
> -Vitaly
>> Thanks.
>>
>> 2008/6/18 Laurent Pinchart <laurentp@cse-semaphore.com>:
>> > The restart() function is called when the link state changes and resets
>> > multicast and promiscous settings. This patch restores those settings at the
>> > end of restart().
>> >
>> > Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
>> > ---
>> >  drivers/net/fs_enet/mac-fcc.c     |    3 +++
>> >  2 files changed, 4 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
>> > index ce40cf9..1a95cf1 100644
>> > --- a/drivers/net/fs_enet/mac-fcc.c
>> > +++ b/drivers/net/fs_enet/mac-fcc.c
>> > @@ -464,6 +464,9 @@ static void restart(struct net_device *dev)
>> >                C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
>> >
>> >        S32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);
>> > +
>> > +       /* Restore multicast and promiscous settings */
>> > +       set_multicast_list(dev);
>> >  }
>> >
>> >  static void stop(struct net_device *dev)
>> > --
>> > 1.5.0
>> >
>> > --
>> > Laurent Pinchart
>> > CSE Semaphore Belgium
>> >
>> > Chaussee de Bruxelles, 732A
>> > B-1410 Waterloo
>> > Belgium
>> >
>> > T +32 (2) 387 42 59
>> > F +32 (2) 387 42 75
>> >
>
>
> --
> Sincerely,
> Vitaly
>
