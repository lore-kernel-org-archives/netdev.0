From: George Dunlap <george.dunlap@eu.citrix.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance regression
 on Xen
Date: Thu, 16 Apr 2015 12:39:12 +0100
Message-ID: <552F9F60.7090406@eu.citrix.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
	 <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
	 <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552E9E8D.1080000@eu.citrix.com>
	 <1429119688.7346.123.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504151846110.7690@kaball.uk.xensource.com>
 <1429121867.7346.136.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"Paul Durrant" <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	<linux-arm-kernel@lists.infradead.org>,
	"David Vrabel" <david.vrabel@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:6004 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754399AbbDPLjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 07:39:43 -0400
In-Reply-To: <1429121867.7346.136.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2015 07:17 PM, Eric Dumazet wrote:
> Do not expect me to fight bufferbloat alone. Be part of the challenge,
> instead of trying to get back to proven bad solutions.

I tried that.  I wrote a description of what I thought the situation
was, so that you could correct me if my understanding was wrong, and
then what I thought we could do about it.  You apparently didn't even
read it, but just pointed me to a single cryptic comment that doesn't
give me enough information to actually figure out what the situation is.

We all agree that bufferbloat is a problem for everybody, and I can
definitely understand the desire to actually make the situation better
rather than dying the death of a thousand exceptions.

If you want help fighting bufferbloat, you have to educate people to
help you; or alternately, if you don't want to bother educating people,
you have to fight it alone -- or lose the battle due to having a
thousand exceptions.

So, back to TSQ limits.  What's so magical about 2 packets being *in the
device itself*?  And what does 1ms, or 2*64k packets (the default for
tcp_limit_output_bytes), have anything to do with it?

Your comment lists three benefits:
1. better RTT estimation
2. faster recovery
3. high rates

#3 is just marketing fluff; it's also contradicted by the statement that
immediately follows it -- i.e., there are drivers for which the
limitation does *not* give high rates.

#1, as far as I can tell, has to do with measuring the *actual* minimal
round trip time of an empty pipe, rather than the round trip time you
get when there's 512MB of packets in the device buffer.  If a device has
a large internal buffer, then having a large number of packets
outstanding means that the measured RTT is skewed.

The goal here, I take it, is to have this "pipe" *exactly* full; having
it significantly more than "full" is what leads to bufferbloat.

#2 sounds like you're saying that if there are too many packets
outstanding when you discover that you need to adjust things, that it
takes a long time for your changes to have an effect; i.e., if you have
5ms of data in the pipe, it will take at least 5ms for your reduced
transmmission rate to actually have an effect.

Is that accurate, or have I misunderstood something?

 -George
