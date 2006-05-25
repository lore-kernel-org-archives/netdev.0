From: "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>
Subject: RE: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Thu, 25 May 2006 16:30:48 +0800
Message-ID: <A975FFC51622704CBEAB749E263D1799015540B5@mail01.student.main.ntu.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <jmorris@namei.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp2.ntu.edu.sg ([155.69.5.9]:30576 "EHLO exsmtp2.ntu.edu.sg")
	by vger.kernel.org with ESMTP id S965088AbWEYIau convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 04:30:50 -0400
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>,
	"Baruch Even" <baruch@ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, I agree. Actually the main contribution of TCP Veno is not in this AI phase. No matter the ABC is added or not, TCP Veno can always improve the performance over wireless networks, according to our tests. 

Best Regards,
Zhou Bin

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@osdl.org]
Sent: Thursday, May 25, 2006 12:47 AM
To: Baruch Even
Cc: #ZHOU BIN#; jmorris@namei.org; netdev@vger.kernel.org
Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13


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
