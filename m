From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Wed, 15 Apr 2015 18:58:07 +0100
Message-ID: <alpine.DEB.2.02.1504151846110.7690@kaball.uk.xensource.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
  <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
  <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
  <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
  <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
  <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
  <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
  <552E9E8D.1080000@eu.citrix.com>
 <1429119688.7346.123.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: George Dunlap <george.dunlap@eu.citrix.com>,
	Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	"Christoffer Dall" <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	<linux-arm-kernel@lists.infradead.org>,
	"David Vrabel" <david.vrabel@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:42164 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbbDOR7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 13:59:44 -0400
In-Reply-To: <1429119688.7346.123.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Apr 2015, Eric Dumazet wrote:
> On Wed, 2015-04-15 at 18:23 +0100, George Dunlap wrote:
> 
> > Which means that max(2*skb->truesize, sk->sk_pacing_rate >>10) is
> > *already* larger for Xen; that calculation mentioned in the comment is
> > *already* doing the right thing.
> 
> Sigh.
> 
> 1ms of traffic at 40Gbit is 5 MBytes
> 
> The reason for the cap to /proc/sys/net/ipv4/tcp_limit_output_bytes is
> to provide the limitation of ~2 TSO packets, which _also_ is documented.
> 
> Without this limitation, 5 MBytes could translate to : Fill the queue,
> do not limit.
> 
> If a particular driver needs to extend the limit, fine, document it and
> take actions.

What actions do you have in mind exactly?  It would be great if you
could suggest how to move forward from here, beside documentation.

I don't think we can really expect every user that spawns a new VM in
the cloud to manually echo blah >
/proc/sys/net/ipv4/tcp_limit_output_bytes to an init script.  I cannot
imagine that would work well.
