From: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Thu, 28 May 2015 10:38:43 -0400 (EDT)
Message-ID: <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com> <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.196]:51702 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752625AbbE1Oiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 10:38:46 -0400
In-Reply-To: <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On May 25, 2015 at 6:31 PM Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
> On Mon, 2015-05-25 at 16:05 -0400, John A. Sullivan III wrote:
> > Hello, all. One one of our connections we are doing intensive traffic
> > shaping with tc. We are using ifb interfaces for shaping ingress
> > traffic and we also use ifb interfaces for egress so that we can apply
> > the same set of rules to multiple interfaces (e.g., tun and eth
> > interfaces operating on the same physical interface).
> >
> > These are running on very powerful gateways; I have watched them
> > handling 16 Gbps with CPU utilization at a handful of percent. Yet, I
> > am seeing drops on the ifb interfaces when I do a tc -s qdisc show.
> >
> > Why would this be? I would expect if there was some kind of problem that
> > it would manifest as drops on the physical interfaces and not the IFB
> > interface. We have played with queue lengths in both directions. We
> > are using HFSC with SFQ leaves so I would imagine this overrides the
> > very short qlen on the IFB interfaces (32). These are drops and not
> > overlimits.
>
> IFB is single threaded and a serious bottleneck.
>
> Don't use this on egress, this destroys multiqueue capaility.
>
> And SFQ is pretty limited (127 packets)
>
> You might try to change your NIC to have a single queue for RX,
> so that you have a single cpu feeding your IFB queue.
>
> (ethtool -L eth0 rx 1)
>
>
>
>
>
This has been an interesting exercise - thank you for your help along the way,
Eric.  IFB did not seem to bottleneck in our initial testing but there was
really only one flow of traffic during the test at around 1 Gbps.  However, on a
non-test system with many different flows, IFB does seem to be a serious
bottleneck - I assume this is the consequence of being single-threaded.

Single queue did not seem to help.

Am I correct to assume that IFB would be as much as a bottleneck on the ingress
side as it would be on the egress side? If so, is there any way to do high
performance ingress traffic shaping on Linux - a multi-threaded version of IFB
or a different approach? Thanks - John
