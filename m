From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 22:36:53 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912032207430.776@melkinpaasi.cs.helsinki.fi>
References: <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <4B17A791.80808@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi> <4B17C6C3.1060000@tvk.rwth-aachen.de>
 <20091203202328.62d7551a@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-1627901596-1259872574=:776"
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48442 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294AbZLCUgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:36:47 -0500
In-Reply-To: <20091203202328.62d7551a@houba>
Content-ID: <alpine.DEB.2.00.0912032236350.776@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1627901596-1259872574=:776
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0912032236351.776@melkinpaasi.cs.helsinki.fi>

On Thu, 3 Dec 2009, Frederic Leroy wrote:

> Le Thu, 03 Dec 2009 15:10:11 +0100,
> Damian Lukowski <damian@tvk.rwth-aachen.de> a écrit :
> > > I suppose adding || !tp->retrans_stamp into the false condition is
> > > fine as long as we don't then have a connection that can cause a
> > > connection to hang there forever for some reason (this needs to be
> > > understood well enough, not just test driven in stables :-)).
> > > 
> > >> Unluckily, I still cannot reproduce the scp stalls here, so it
> > >> would be nice if Frederic printed retrans_stamp together with
> > >> icsk_ca_state and icsk_retransmits, please.
> > > 
> > > It wouldn't hurt to know tp->packets_out and tp->retrans_out too,
> > > that might have some significant w.r.t what happens because of FRTO.
> > 
> > I made a patch for Frederic with Codebase
> > git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> > 
> > Thanks for testing.
> 
> I made a new .11 trace with damian patch.
> The copy went to the end. 
> 
> http://www.starox.org/pub/scp_stall/scp_stall-houba.11-patch_damian.pcap.bz2
> http://www.starox.org/pub/scp_stall/scp_stall-houba.11-patch_damian.dmesg.bz2
> http://www.starox.org/pub/scp_stall/scp_stall-houba.11-patch_damian.proc_net_netstat-before.bz2
> http://www.starox.org/pub/scp_stall/scp_stall-houba.11-patch_damian.proc_net_netstat-after.bz2
> http://www.starox.org/pub/scp_stall/scp_stall-houba.11-patch_damian.sysctl_net.ipv4.tcp-before.bz2

So the || !tp->retrans_stamp certainly solves the silent death, however, 
annoying thing is that now we didn't get get the zero events logged :-).
Can you please print them also in that branch. Also, I forgot previously 
that tp->frto_counter would be nice to know. And since there seems to be a 
need for yet another case, in order to solve the other problem related to 
fast retransmit, also tp->lost_out and tp->sacked_out would be nice to
know.

MIBs tell:
...24 SACK recoveries started but never any retransmission in them...
...DSACK undo counter is probably miscounting, 28 is way too much to be 
realistic for those two DSACKs received :-). It might relate to this not 
retransmitting anything.

-- 
 i.
---696230645-1627901596-1259872574=:776--
