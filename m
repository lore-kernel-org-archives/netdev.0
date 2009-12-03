From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 16:36:18 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912031630390.7024@wel-95.cs.helsinki.fi>
References: <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <4B17CABE.8070402@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-709105506-1259850978=:7024"
Cc: Frederic Leroy <fredo@starox.org>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57023 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbZLCOgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 09:36:14 -0500
In-Reply-To: <4B17CABE.8070402@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-709105506-1259850978=:7024
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 3 Dec 2009, Arnd Hannemann wrote:

> Ilpo Järvinen wrote:
> 
> [snipped]
> 
> > Also, we have the another mystery to be solved, the fast retransmission is 
> > not triggered for some reason (or alternatively not captured in to a 
> > log), even in the working .9. case. It would be easy to see whether it 
> > works at all from TCP point of view by looking into mibs once you have 
> > have some transfers in a working configuration:
> > 
> > grep -A1 TCP /proc/net/netstat
> > 
> > ...luckily this fast retransmit issue is less crucial as almost all people 
> > are pretty happy already if their RTO-based recovery works even if the 
> > fast recovery would not. So figuring it out can be postponed (if one has 
> > to prioritize) until the silent death issue is out of the way.
> > 
> > 
> 
> I looked at the working .9 case stream from 192.168.1.15 to 192.168.1.19.
> I don't think it is a mystery that fast retransmit does not trigger.
> The condition SACKED_DATA > 3* SMSS is simply not fulfilled.
> Neither are there 3 non-continuous SACK sequences.
> The segments sent are too small :-(
> Interesting though, seems to me in this case non-SACK would be better than SACK.
> Or did I miss something?

Yes, a particularly big one, linux does not count SACKs bytes but packets. 
In the first recovery, plenty of packets are SACKed:

    135 sack 1 {2598:2646}>
    108 sack 1 {2598:2694}>
    121 sack 1 {2598:2742}>
     95 sack 1 {2598:2790}>
    426 sack 1 {2598:2838}>

fackets_out should be 6 now which is way more than 3 which is the 
default tp->reordering.

> Hey we could cook up a draft for this problem ;-)
>
> Anyway, real problem is, RTO does not trigger...

There are two problems. ...Both are real. ;-) But significance of the 
other is much worse than the other.

-- 
 i.
--8323329-709105506-1259850978=:7024--
