From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Crazy TCP bug (keepalive flood?) in 2.6.32?
Date: Sat, 23 Jan 2010 23:37:19 +0200
Message-ID: <201001232337.19122.denys@visp.net.lb>
References: <200912261703.49067.denys@visp.net.lb> <201001191309.03927.denys@visp.net.lb> <alpine.DEB.2.00.1001191308490.14108@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:47127 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783Ab0AWVfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 16:35:10 -0500
In-Reply-To: <alpine.DEB.2.00.1001191308490.14108@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 19 January 2010 13:17:51 you wrote:
> On Tue, 19 Jan 2010, Denys Fedoryshchenko wrote:
> > On Tuesday 19 January 2010 11:10:12 you wrote:
> > > Hi,
> > > thank you for testing. So srtt and rttvar is zero in any of those
> > > cases. Ilpo, it is a bug in tcp_rtt_estimator then, I suppose?
> > >
> > > There is also a code comment in tcp_input.c, saying:
> > > > * NOTE: clamping at TCP_RTO_MIN is not required, current algo
> > > > * guarantees that rto is higher.
> > >
> > > So we either fix tcp_rtt_estimator or simply clamp at TCP_RTO_MIN?
> > >
> > > Damian
> > >
> > > > On Monday 11 January 2010 15:02:34 you wrote:
> > > >> On Sat, 26 Dec 2009, Denys Fedoryshchenko wrote:
> > > >>> Few more dumps. I notice:
> > > >>> 1)Ack always equal 1
> > > >>> 2)It is usually first segment of data sent (?)
> > > >>>
> > > >>> Maybe some value not initialised properly?
> > > >>
> > > >> Can you see if the RTO lower bound is violated (I added some
> > > >> printing of vars there too already now if it turns out to be
> > > >> something):
> > > >>
> > > >> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> > > >> index 65b8ebf..d84469f 100644
> > > >> --- a/net/ipv4/tcp_ipv4.c
> > > >> +++ b/net/ipv4/tcp_ipv4.c
> >
> > As i see in code it is rounding RTO to minimum value.
> > It fixes my problem seems.
> >
> > Btw just a bit about my environment - wireless networks (sometimes
> > lossy!) with low speed (128-512Kbps) customers working over pppoe. Maybe
> > it will give a tip why rtt value is too low.
> 
> What I find most strange in it is the fact that when it triggers for the
> first time, the srtt and mdev are zero, not some value in between 0 and
> 200ms. Therefore I suspect that this case might be something that we've
> overlooked where srtt/mdev are not valid at all.
> 
> Maybe the patch below helps...
> 
Seems after this patch (and debug patch with warnings) my dmesg is clean.
