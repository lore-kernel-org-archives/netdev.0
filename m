From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 21 Jun 2011 14:46:11 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1106211444210.17529@wel-95.cs.helsinki.fi>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com> <D0D2412D-2D30-4051-B346-32D20858BC92@nets.rwth-aachen.de> <alpine.DEB.2.00.1106211423400.17529@wel-95.cs.helsinki.fi> <201106211334.17825.carsten@wolffcarsten.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1887077171-1308656771=:17529"
Cc: Alexander Zimmermann <zimmermann@nets.rwth-aachen.de>,
	Dominik Kaspar <dokaspar.ietf@gmail.com>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Carsten Wolff <carsten@wolffcarsten.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33789 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663Ab1FULqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 07:46:12 -0400
In-Reply-To: <201106211334.17825.carsten@wolffcarsten.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1887077171-1308656771=:17529
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Tue, 21 Jun 2011, Carsten Wolff wrote:

> On Tuesday 21 June 2011, Ilpo Järvinen wrote:
> > On Wed, 27 Apr 2011, Alexander Zimmermann wrote:
> > > Am 27.04.2011 um 18:22 schrieb Dominik Kaspar:
> > > > Hi Carsten,
> > > > 
> > > > Thanks for your feedback. I made some new tests with the same setup of
> > > > packet-based forwarding over two emulated paths (600 KB/s, 10 ms) +
> > > > (400 KB/s, 100 ms). In the first experiments, which showed a step-wise
> > > > adaptation to reordering, SACK, DSACK, and Timestamps were all
> > > > enabled. In the experiments, I individually disabled these three
> > > > mechanisms and saw the following:
> > > > 
> > > > - Disabling timestamps causes TCP to never adjust to reordering at all.
> > > 
> > > Reordering detection with DSACK is broken in Linux. We will fix that in
> > > a couple of weeks...
> > > 
> > > > - Disabling SACK allows TCP to adapt very rapidly ("perfect"
> > > > aggregation!).
> > > 
> > > If you disable SACK, you will use the NewReno detection
> > 
> > Which probably has some reordering over-estimate bugs on its own...
> > (but I've forgotten details of my suspicion long time ago so please don't
> > ask for the them).
> 
> the NewReno detection is clever, but there's no exact information it could 
> utilize for a good metric, because it detects the event too late, when the 
> information is already gone. In my experiments it always under-estimated the 
> reordering extent, though. I also remmember thinking that the metric of the 
> Eifel-detection has an off-by-one bug.

That might be true for most of the cases but IIRC I figured out a
a scenario where it miscalculates RTT worth of extra into the reordering 
(but I never really confirmed that in real tests or so, just figured it 
a bit).

-- 
 i.
--8323329-1887077171-1308656771=:17529--
