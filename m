From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Wed, 24 May 2006 09:46:30 -0700
Message-ID: <20060524094630.6fb7cdff@localhost.localdomain>
References: <A975FFC51622704CBEAB749E263D1799015540B3@mail01.student.main.ntu.edu.sg>
	<447486F4.1050307@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: #ZHOU BIN# <ZHOU0022@ntu.edu.sg>, jmorris@namei.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32175 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932396AbWEXQqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 12:46:43 -0400
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <447486F4.1050307@ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 May 2006 17:16:52 +0100
Baruch Even <baruch@ev-en.org> wrote:

> #ZHOU BIN# wrote:
> > From: Bin Zhou <zhou0022@ntu.edu.sg>
> > +		else if (sysctl_tcp_abc) {
> > + 			/* RFC3465: Apppriate Byte Count
> > + 	 		* increase once for each full cwnd acked.
> > + 	 		* Veno has no idear about it so far, so we keep
> > + 	 		* it as Reno.
> > + 	 		*/
> > + 			if (tp->bytes_acked >= tp->snd_cwnd*tp->mss_cache) {
> > + 				tp->bytes_acked -= tp->snd_cwnd*tp->mss_cache;
> > + 				if (tp->snd_cwnd < tp->snd_cwnd_clamp)
> > + 					tp->snd_cwnd++;
> > + 			}
> 
> You should prefer to ignore abc instead. At least that's what everyone
> else is doing, the only place where abc is active is in NewReno.
> 
> Baruch

That was intentional. When ABC was added, the desire was to not change existing
behavior for other congestion control methods.
