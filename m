From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: Re: [net-next v2 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon, 17 Feb 2014 18:57:25 +0100
Message-ID: <201402171857.25635.sw@simonwunderlich.de>
References: <1392656174-14791-1-git-send-email-sw@simonwunderlich.de> <1392656174-14791-4-git-send-email-sw@simonwunderlich.de> <5302474B.6090609@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55795 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbaBQR53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 12:57:29 -0500
In-Reply-To: <5302474B.6090609@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 02/17/14 17:56, Simon Wunderlich wrote:
> > MPLS labels may contain traffic control information, which should be
> > evaluated and used by the wireless subsystem if present.
> > 
> > Also check for IEEE 802.21 which is always network control traffic.
> > 
> > Signed-off-by: Simon Wunderlich<sw@simonwunderlich.de>
> > Signed-off-by: Mathias Kretschmer<mathias.kretschmer@fokus.fraunhofer.de>
> > ---
> > 
> > Changes to first version:
> >   * include linux/mpls.h, not the UAPI one
> >   * change __constant_htons to htons
> > 
> > ---
> > 
> >   net/wireless/util.c |   24 ++++++++++++++++++++++++
> >   1 file changed, 24 insertions(+)
> > 
> > diff --git a/net/wireless/util.c b/net/wireless/util.c
> > index d39c371..54956eb 100644
> > --- a/net/wireless/util.c
> > +++ b/net/wireless/util.c
> > @@ -11,6 +11,7 @@
> > 
> >   #include<net/ip.h>
> >   #include<net/dsfield.h>
> >   #include<linux/if_vlan.h>
> > 
> > +#include<linux/mpls.h>
> > 
> >   #include "core.h"
> >   #include "rdev-ops.h"
> > 
> > @@ -710,6 +711,29 @@ unsigned int cfg80211_classify8021d(struct sk_buff
> > *skb,
> 
> So does the name still covers what it is doing now or should we just
> callit cfg80211_classify_skb()?

I'm not completely sure why this function is called 8021d anyway (isn't 802.1D 
the Spanning Tree definition?). The actual QoS definitions are appearently in 
802.1p. But I don't know both standards, so I'm just speculating. :) We can 
rename the function, but that would require more changes in drivers and 
mac80211.

Anyway, I can resend the patch along with a rename, but would prefer to get 
the first two proposed patches merged first if there are no further objections.

Cheers,
    Simon
