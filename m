From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 14:49:11 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi>
References: <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <4B17A791.80808@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frederic Leroy <fredo@starox.org>, Netdev <netdev@vger.kernel.org>,
	Asdo <asdo@shiftmail.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37448 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbZLCMtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:49:06 -0500
In-Reply-To: <4B17A791.80808@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Dec 2009, Damian Lukowski wrote:

> > On Thu, 3 Dec 2009, Frederic Leroy wrote:
> >> On Wed, Dec 02, 2009 at 08:17:44PM +0100, Damian Lukowski wrote:
> >>> could you please printk retrans_stamp just before the return in 
> >>> include/net/tcp.h:retransmits_timed_out()?
> >>> If the value is not monotonically increasing but is reset to 0 at some
> >>> point, this might lead to problems in tcp_write_timeout().
> >>> It's the only idea I have now.
> >> Your idea is good.
> >> Only one out of 4 value is not null.
> >>
> >> Logs corresponding on http://wwW.starox.org/pub/scp_stall is .10
> >>
> >> I make 2 attempts. Printk corresponding to .10 are those after the line 
> >> "wlan1 enter promiscuous mode"
> > 
> > Nice thinking indeed Damian, thanks. ...But but, where exactly did you 
> > print? ...There are multiple returns and the return false branch is 
> > expected to have a zero retrans_stamp in a typical case but that is not
> > a problem because we never use the value.
> 
> Yes, it's the retrans_stamp in the subtraction I suspected to be 0.
> I also suspect this to happen only in the ca_state < CA_Loss case,
> so one first solution might be to return true whenever retrans_stamp == 0.

I suppose adding || !tp->retrans_stamp into the false condition is fine 
as long as we don't then have a connection that can cause a connection 
to hang there forever for some reason (this needs to be understood well 
enough, not just test driven in stables :-)).

> Unluckily, I still cannot reproduce the scp stalls here, so it would be nice
> if Frederic printed retrans_stamp together with icsk_ca_state and
> icsk_retransmits, please.

It wouldn't hurt to know tp->packets_out and tp->retrans_out too, that 
might have some significant w.r.t what happens because of FRTO.


-- 
 i.
