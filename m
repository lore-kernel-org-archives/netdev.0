From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6 0/3]: Three TCP fixes
Date: Tue, 4 Dec 2007 23:10:33 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712042252450.12072@kivilampi-30.cs.helsinki.fi>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
 <47559FA1.2090104@psc.edu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-907943039-1196802633=:12072"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36439 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755421AbXLDVKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 16:10:35 -0500
In-Reply-To: <47559FA1.2090104@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-907943039-1196802633=:12072
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 4 Dec 2007, John Heffner wrote:

> Ilpo Järvinen wrote:
> > ...I'm still to figure out why tcp_cwnd_down uses snd_ssthresh/2
> > as lower bound even though the ssthresh was already halved, so snd_ssthresh
> > should suffice.
> 
> I remember this coming up at least once before, so it's probably worth a
> comment in the code.  Rate-halving attempts to actually reduce cwnd to half
> the delivered window.  Here, cwnd/4 (ssthresh/2) is a lower bound on how far
> rate-halving can reduce cwnd.  See the "Bounding Parameters" section of
> <http://www.psc.edu/networking/papers/FACKnotes/current/>.

Thanks for the info! Sadly enough it makes NewReno recovery quite 
inefficient when there are enough losses and high BDP link (in my case 
384k/200ms, BDP sized buffer). There might be yet another bug in it as 
well (it is still a bit unclear how tcp variables behaved during my 
scenario and I'll investigate further) but reduction in the transfer 
rate is going to last longer than a short moment (which is used as 
motivation in those FACK notes). In fact, if I just use RFC2581 like 
setting w/o rate-halving (and experience the initial "pause" in sending), 
the ACK clock to send out new data works very nicely beating rate halving 
fair and square. For SACK/FACK it works much nicer because recovery is 
finished much earlier and slow start recovers cwnd quickly.


...Mind if I ask another similar one, any idea why prior_ssthresh is 
smaller (3/4 of it) than cwnd used to be (see tcp_current_ssthresh)?


-- 
 i.
---696243703-907943039-1196802633=:12072--
