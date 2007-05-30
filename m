From: "Laurent Chavey" <chavey@google.com>
Subject: Re: bond_compute_features() does not handle devices with different CSUM
Date: Wed, 30 May 2007 08:16:00 -0700
Message-ID: <97949e3e0705300816v782b20edsf366bbe5de6a6d36@mail.gmail.com>
References: <97949e3e0705291741t4c485d38ud48b06e6d07e31bc@mail.gmail.com>
	 <97949e3e0705291947j7fa5cd3fy5afe7f5eb898252c@mail.gmail.com>
	 <200705301303.25119.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:37289 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464AbXE3PQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 11:16:22 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id l4UFG9Ss024399
	for <netdev@vger.kernel.org>; Wed, 30 May 2007 08:16:10 -0700
Received: from an-out-0708.google.com (anac8.prod.google.com [10.100.54.8])
	by zps75.corp.google.com with ESMTP id l4UFFVEf025223
	for <netdev@vger.kernel.org>; Wed, 30 May 2007 08:16:01 -0700
Received: by an-out-0708.google.com with SMTP id c8so872029ana
        for <netdev@vger.kernel.org>; Wed, 30 May 2007 08:16:01 -0700 (PDT)
In-Reply-To: <200705301303.25119.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

features = features & (dev_features & BOND_INTERSECT_FEATURES);

On 5/30/07, Michael Buesch <mb@bu3sch.de> wrote:
> On Wednesday 30 May 2007 04:47:09 Laurent Chavey wrote:
> > proposed change.
> >
> > --- 2.6.20/drivers/net/bonding/bond_main.c      2007-05-29
> > 19:43:39.010565000 -0700
> > +++ 2.6.20.fix/drivers/net/bonding/bond_main.c  2007-05-29
> > 19:46:12.376980000 -0700
> > @@ -1227,7 +1227,14 @@
> >         int i;
> >
> >         bond_for_each_slave(bond, slave, i) {
> > -               features &= (slave->dev->features & BOND_INTERSECT_FEATURES);
> > +               /* NETIF_F_HW_CSUM includes support for NET_IF_IP_CSUM
> > +                * as such when looking for the intersection we need to
> > +                * add it to the device supported features
> > +                */
> > +               unsigned long dev_features = slave->dev->features;
> > +               if (slave->dev->features & NETIF_F_HW_CSUM)
> > +                       dev_features |= NETIF_F_IP_CSUM;
>
>
> > +               features &= (features & BOND_INTERSECT_FEATURES);
>
> Is this statement correct?
> It's the same as
>         features = features & (features & BOND_INTERSECT_FEATURES);
> which looks strange to me.
> Did you mean something like
>         features |= (dev_features & BOND_INTERSECT_FEATURES);
> ?
>
> --
> Greetings Michael.
>
