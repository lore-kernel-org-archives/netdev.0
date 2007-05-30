From: "Laurent Chavey" <chavey@google.com>
Subject: Re: bond_compute_features() does not handle devices with different CSUM
Date: Wed, 30 May 2007 09:58:38 -0700
Message-ID: <97949e3e0705300958u1e162f14k3abdca2d8663c4b@mail.gmail.com>
References: <97949e3e0705291741t4c485d38ud48b06e6d07e31bc@mail.gmail.com>
	 <20070530092757.3417fb52@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:37461 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbXE3Q6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 12:58:51 -0400
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id l4UGwkp4014992
	for <netdev@vger.kernel.org>; Wed, 30 May 2007 17:58:46 +0100
Received: from an-out-0708.google.com (anac31.prod.google.com [10.100.54.31])
	by spaceape10.eur.corp.google.com with ESMTP id l4UGwcLY030056
	for <netdev@vger.kernel.org>; Wed, 30 May 2007 17:58:39 +0100
Received: by an-out-0708.google.com with SMTP id c31so703614ana
        for <netdev@vger.kernel.org>; Wed, 30 May 2007 09:58:38 -0700 (PDT)
In-Reply-To: <20070530092757.3417fb52@freepuppy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

should we then move/integrate that code as part of the bonding driver ?


On 5/30/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Tue, 29 May 2007 17:41:45 -0700
> "Laurent Chavey" <chavey@google.com> wrote:
>
> > kernel version <= 2.6.20.1
> > file drivers/net/bonding/bonding_main.c
> > function bond_compute_features()
> >
> > -----------
> >   Given a system with two different NIC. One driver sets
> >         dev->features |=  NETIF_F_HW_CSUM
> >   the other driver sets
> >         dev->features |=  NETIF_F_IP_CSUM
> >
> >   when enslaving the 2 device above, bond_compute_features()
> >   does not set the intersection of the 2 CSUM
> >   features (should be NETIF_F_IP_CSUM)
> > -----------
> >
> >    should the bond features in the case above include NETIF_F_IP_CSUM
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> The bridge code already has a more complete/complex recompute
> routine to handle this.
>
> --
> Stephen Hemminger <shemminger@linux-foundation.org>
>
