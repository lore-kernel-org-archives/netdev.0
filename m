From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Mon, 30 Nov 2009 21:10:20 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911302105230.9826@melkinpaasi.cs.helsinki.fi>
References: <20091127223545.2a752429@houba> <alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi> <20091128010156.1219012a@houba> <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi> <20091130195004.38dbc319@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-1741470023-1259608220=:9826"
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38371 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbZK3TKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 14:10:14 -0500
In-Reply-To: <20091130195004.38dbc319@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1741470023-1259608220=:9826
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Mon, 30 Nov 2009, Frederic Leroy wrote:

> Le Sat, 28 Nov 2009 13:31:14 +0200 (EET),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> 
> > On Sat, 28 Nov 2009, Frederic Leroy wrote:
> > 
> > > Le Sat, 28 Nov 2009 00:12:23 +0200 (EET),
> > > "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> > > 
> > > > On Fri, 27 Nov 2009, Frederic Leroy wrote:
> > > > 
> > > > > I put traces of stall here : 
> > > > > http://www.starox.org/pub/scp_stall/
> > [...]
> > Perhaps having the /proc/net/tcp would at least tell what state the
> > timer is (if I cannot reproduce right away). ...It is rather strange
> > that two independent mechanisms for loss recovery seem both to fail
> > to get triggered here, no traces of retransmission whatsoever. I
> > think it is for now enough to concentrate on what happens on
> > 192.168.1.15 (=houba?) and get tcpdump and proc/net/tcp from there,
> > the other end/direction has very little significance here (except for
> > the fact that bidirectionality might be needed to actually trigger
> > it). You could even think of getting proc/net/tcp a bit more often,
> > right from the start:
> > 
> > while [ : ]; do grep ":0016" /proc/net/tcp; sleep 0.1; done | tee
> > scp_stall-houba.x.proc_net_tcp
> > 
> > ...Please wait at least 2 minutes before hitting ctrl-c or otherwise 
> > artificially intervening.
> 
> You're right, 192.168.1.15 is houba.
> The faulty behaviour comes back today, I did new captures on
> 192.168.1.15 only : 
> http://www.starox.org/pub/scp_stall/scp_stall-houba.2.pcap
> http://www.starox.org/pub/scp_stall/scp_stall-houba.2.proc_net_tcp
> http://www.starox.org/pub/scp_stall/scp_stall-houba.3.pcap
> http://www.starox.org/pub/scp_stall/scp_stall-houba.3.proc_net_tcp

Thanks, I'll take a look.

> Which tool do you use to analyze /proc/net/tcp ?

I just recall the order of fields from net/ipv4/tcp_ipv4.c and apply my 
knowledge about TCP internals from there on. ...I've no particularly fancy 
tools for the job.

-- 
 i.
---696230645-1741470023-1259608220=:9826--
