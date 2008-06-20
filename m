From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: Re: [PATCH] fs_enet: restore promiscuous and multicast settings in restart()
Date: Fri, 20 Jun 2008 12:55:22 +0400
Message-ID: <8496f91a0806200155hcb1f440ld7b5f678d95fdb85@mail.gmail.com>
References: <200806181707.17739.laurentp@cse-semaphore.com>
	 <20080619230128.def96ee0.billfink@mindspring.com>
	 <200806201025.28768.laurentp@cse-semaphore.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Bill Fink" <billfink@mindspring.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com
To: "Laurent Pinchart" <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:43385 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbYFTIzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 04:55:22 -0400
Received: by wa-out-1112.google.com with SMTP id j37so858589waf.23
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2008 01:55:22 -0700 (PDT)
In-Reply-To: <200806201025.28768.laurentp@cse-semaphore.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
>> > index ce40cf9..1a95cf1 100644
>> > --- a/drivers/net/fs_enet/mac-fcc.c
>> > +++ b/drivers/net/fs_enet/mac-fcc.c
>> > @@ -464,6 +464,9 @@ static void restart(struct net_device *dev)
>> >             C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
>> >
>> >     S32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);
>> > +
>> > +   /* Restore multicast and promiscous settings */
>> > +   set_multicast_list(dev);
>> >  }

Is it right to call set_multicast_list() after turning on transmitter
and receiver? May be swap this lines around?
