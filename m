From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/4] [RFC] virtio-net: Improve small packet performance
Date: Thu, 5 May 2011 18:37:27 +0300
Message-ID: <20110505153727.GD1915@redhat.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
 <20110504144622.GA15823@redhat.com>
 <OFAEA8C363.C13C507B-ON65257886.0051F71F-65257886.0052217F@in.ibm.com>
 <20110504212359.GA21446@redhat.com>
 <OF2E0182A1.3818A07E-ON65257887.00225EE8-65257887.002C000C@in.ibm.com>
 <20110505090439.GD17647@redhat.com>
 <OFB1ACC9EB.4567C1B1-ON65257887.0050044B-65257887.0054A5CE@in.ibm.com>
 <OF32D1B981.C4616456-ON65257887.00552498-65257887.00555A3C@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753999Ab1EEPhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 11:37:46 -0400
Content-Disposition: inline
In-Reply-To: <OF32D1B981.C4616456-ON65257887.00552498-65257887.00555A3C@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2011 at 09:06:00PM +0530, Krishna Kumar2 wrote:
> Krishna Kumar wrote on 05/05/2011 08:57:13 PM:
> 
> Oops, I sent my patch's test results for the 16K case.
> The correct one is:
> 
> ________________________________________________________
>                   I/O size: 16K
> #       BW1     BW2 (%)         SD1     SD2 (%)
> ________________________________________________________
> 1       6684    6670 (-.2)      1.1     .6 (-45.4)
> 2       7674    7859 (2.4)      5.0     2.6 (-48.0)
> 4       7358    7421 (.8)       21.3    11.6 (-45.5)
> 8       7393    7289 (-1.4)     82.7    44.8 (-45.8)
> 16      7958    7280 (-8.5)     283.2   166.3 (-41.2)
> 32      7792    7163 (-8.0)     1257.5  692.4 (-44.9)
> 64      7673    7096 (-7.5)     5723.1  2870.3 (-49.8)
> 96      7462    6963 (-6.6)     12731.8 6475.6 (-49.1)
> 128     7338    6919 (-5.7)     21331.7 12345.7 (-42.1)
> ________________________________________________________
> Summary:    BW: (-3.9)      SD: (-45.4)
> 
> Sorry for the confusion.
> 
> Regards,
> 
> - KK

Interesting. So which is which?
> > ________________________________________________________
> >                   I/O size: 16K
> > #     BW1     BW2 (%)        SD1       SD2 (%)
> > ________________________________________________________
> > 1     6684    7019 (5.0)     1.1       1.1 (0)
> > 2     7674    7196 (-6.2)    5.0       4.8 (-4.0)
> > 4     7358    8032 (9.1)     21.3      20.4 (-4.2)
> > 8     7393    8015 (8.4)     82.7      82.0 (-.8)
> > 16    7958    8366 (5.1)     283.2     310.7 (9.7)
> > 32    7792    8113 (4.1)     1257.5    1363.0 (8.3)
> > 64    7673    8040 (4.7)     5723.1    5812.4 (1.5)
> > 96    7462    7883 (5.6)     12731.8   12119.8 (-4.8)
> > 128   7338    7800 (6.2)     21331.7   21094.7 (-1.1)
> > ________________________________________________________
> > Summary:     BW: (4.6)     SD: (-1.5)
