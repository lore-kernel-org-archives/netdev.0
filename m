From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Wed, 2 Dec 2009 14:59:20 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
References: <20091127223545.2a752429@houba> <alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi> <20091128010156.1219012a@houba> <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi> <20091130195004.38dbc319@houba>
 <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi> <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
 <20091202085925.472136e2@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-1808783674-1259758134=:20416"
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39103 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbZLBM7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 07:59:16 -0500
In-Reply-To: <20091202085925.472136e2@houba>
Content-ID: <alpine.DEB.2.00.0912021449140.20416@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1808783674-1259758134=:20416
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0912021449141.20416@melkinpaasi.cs.helsinki.fi>

On Wed, 2 Dec 2009, Frederic Leroy wrote:

> Le Tue, 1 Dec 2009 22:27:01 +0200 (EET),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> 
> > On Tue, 1 Dec 2009, Frederic Leroy wrote:
> >
> > Thanks, I'll hopefully have some time tomorrow to go through all the
> > new ones.

Thanks for the logs. ...It is very much confirmed now that the connection 
suddently dies.

What is directly inferrable from the logs: Losses happen. RTO is triggered 
for the first time (for some reason also fast retransmit is missing and it 
most likely it should have preceeded RTO), however, the retransmission 
that RTO should make is never captured into the tcpdump. Then when RTO 
triggers for the second time, the connection silently dies immediately and 
consistently for some reason. ...From that point on resets are sent if the 
peer keeps trying.

> > Also,
> > I wonder if you have had some working (past) kernel version?
> 
> I tried a 2.6.31, and it seems to work. If it really work (connection
> don't stall everytime at the moment), I'll try to make a "git bisect"
> asap.

In one of the cases, also the sg end dies (the 4th case). I suppose that 
was running earlier kernel already?

-- 
 i.
---696230645-1808783674-1259758134=:20416--
