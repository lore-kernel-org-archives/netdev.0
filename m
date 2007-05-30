From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bond_compute_features() does not handle devices with different CSUM
Date: Wed, 30 May 2007 13:03:24 +0200
Message-ID: <200705301303.25119.mb@bu3sch.de>
References: <97949e3e0705291741t4c485d38ud48b06e6d07e31bc@mail.gmail.com> <97949e3e0705291947j7fa5cd3fy5afe7f5eb898252c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Laurent Chavey" <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:50778
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbXE3LD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 07:03:59 -0400
In-Reply-To: <97949e3e0705291947j7fa5cd3fy5afe7f5eb898252c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 30 May 2007 04:47:09 Laurent Chavey wrote:
> proposed change.
> 
> --- 2.6.20/drivers/net/bonding/bond_main.c      2007-05-29
> 19:43:39.010565000 -0700
> +++ 2.6.20.fix/drivers/net/bonding/bond_main.c  2007-05-29
> 19:46:12.376980000 -0700
> @@ -1227,7 +1227,14 @@
>         int i;
> 
>         bond_for_each_slave(bond, slave, i) {
> -               features &= (slave->dev->features & BOND_INTERSECT_FEATURES);
> +               /* NETIF_F_HW_CSUM includes support for NET_IF_IP_CSUM
> +                * as such when looking for the intersection we need to
> +                * add it to the device supported features
> +                */
> +               unsigned long dev_features = slave->dev->features;
> +               if (slave->dev->features & NETIF_F_HW_CSUM)
> +                       dev_features |= NETIF_F_IP_CSUM;


> +               features &= (features & BOND_INTERSECT_FEATURES);

Is this statement correct?
It's the same as
	features = features & (features & BOND_INTERSECT_FEATURES);
which looks strange to me.
Did you mean something like
	features |= (dev_features & BOND_INTERSECT_FEATURES);
?

-- 
Greetings Michael.
