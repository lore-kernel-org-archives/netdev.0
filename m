From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Sat, 28 Nov 2009 13:31:14 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi>
References: <20091127223545.2a752429@houba> <alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi> <20091128010156.1219012a@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-317597291-1259405851=:25587"
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46136 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbZK1LbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 06:31:09 -0500
In-Reply-To: <20091128010156.1219012a@houba>
Content-ID: <alpine.DEB.2.00.0911281257390.25587@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-317597291-1259405851=:25587
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911281257391.25587@melkinpaasi.cs.helsinki.fi>

I restored Ccs. Please keep them.

On Sat, 28 Nov 2009, Frederic Leroy wrote:

> Le Sat, 28 Nov 2009 00:12:23 +0200 (EET),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> 
> > On Fri, 27 Nov 2009, Frederic Leroy wrote:
> > 
> > > I put traces of stall here : 
> > > http://www.starox.org/pub/scp_stall/
> >
> > Your proc/net/tcp capture on houba was perhaps made too late? ...The 
> > connection is missing already.
> 
> It could be ! I had a doubt while using my 2 keyboards ... 
> 
> For information for the pcaps, I filtered and used "tcpdump ... ether
> host xx:xx:xx:xx:xx"
> I waited a bit after the stall and kill the scp with ctrl-c.
> 
> > But anyway, at least the problem is visible...
> 
> Great!
> 
> > It seems that
> > 3998:4046 gets never retransmitted, not even by RTO which seems very
> > very strange to me... And after this: 23:21:56.154269 IP
> > 192.168.1.19.50028 > 192.168.1.15.22: . ack 3998 win 379 ... sack 3 
> > {4238:4286}{4142:4190}{4046:4094}> also fast retransmit should have 
> > already triggered. ...I'll look more into this if I can figure it out 
> > from the current traces but it'll take a while.
> 
> Can it help you, if I make other traces ?
> 
> I won't be available until monday.

Perhaps having the /proc/net/tcp would at least tell what state the timer 
is (if I cannot reproduce right away). ...It is rather strange that two 
independent mechanisms for loss recovery seem both to fail to get 
triggered here, no traces of retransmission whatsoever. I think it is for 
now enough to concentrate on what happens on 192.168.1.15 (=houba?) and 
get tcpdump and proc/net/tcp from there, the other end/direction has very 
little significance here (except for the fact that bidirectionality might 
be needed to actually trigger it). You could even think of getting 
proc/net/tcp a bit more often, right from the start:

while [ : ]; do grep ":0016" /proc/net/tcp; sleep 0.1; done | tee scp_stall-houba.x.proc_net_tcp

...Please wait at least 2 minutes before hitting ctrl-c or otherwise 
artificially intervening.

-- 
 i.
---696230645-317597291-1259405851=:25587--
