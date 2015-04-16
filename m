From: George Dunlap <george.dunlap@eu.citrix.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance regression
 on Xen
Date: Thu, 16 Apr 2015 11:01:30 +0100
Message-ID: <552F887A.4060708@eu.citrix.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
	 <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
	 <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552E9E8D.1080000@eu.citrix.com>
	 <1429118948.7346.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552EA2BC.5000707@eu.citrix.com>
	 <1429120373.7346.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552EA844.5010308@eu.citrix.com>
 <1429121979.7346.138.camel@edumazet-glaptop2.roam.corp.google.com>
 <552F7936.9070205@eu.citrix.com> <552F7EF4.9030107@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"Stefano Stabellini" <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"Paul Durrant" <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	<linux-arm-kernel@lists.infradead.org>,
	"David Vrabel" <david.vrabel@citrix.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:58086 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754399AbbDPKCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 06:02:01 -0400
In-Reply-To: <552F7EF4.9030107@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2015 10:20 AM, Daniel Borkmann wrote:
> So mid term, it would be much more beneficial if you attempt fix the
> underlying driver issues that actually cause high tx completion delays,
> instead of reintroducing bufferbloat. So that we all can move forward
> and not backwards in time.

Yes, I think we definitely see the need for this.  I think we certainly
agree that bufferbloat needs to be reduced, and minimizing the data we
need "in the pipe" for full performance on xennet is an important part
of that.

It should be said, however, that any virtual device is always going to
have higher latency than a physical device.  Hopefully we'll be able to
get the latency of xennet down to something that's more "reasonable",
but it may just not be possible.  And in any case, if we're going to be
cranking down these limits to just barely within the tolerance of
physical NICs, virtual devices (either xennet or virtio_net) are never
going to be able to catch up.  (Without cheating that is.)

> What Eric described to you was that you introduce a new netdev member
> like netdev->needs_bufferbloat, set that indication from driver site,
> and cache that in the socket that binds to it, so you can adjust the
> test in tcp_xmit_size_goal(). It should merely be seen as a hint/indication
> for such devices. Hmm?

He suggested that after he'd been prodded by 4 more e-mails in which two
of us guessed what he was trying to get at.  That's what I was
complaining about.

Having a per-device "long transmit latency" hint sounds like a sensible
short-term solution to me.

 -George
