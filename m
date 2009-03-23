From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: ucc_geth: nf_conntrack: table full, dropping packet.
Date: Mon, 23 Mar 2009 14:09:42 +0100
Message-ID: <OF1DAB7314.0782CAC0-ONC1257582.0047DC36-C1257582.00484C76@transmode.se>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF387EC803.F810F72A-ONC1257582.00468C6E-C1257582.00475783@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: avorontsov@ru.mvista.com, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:52846 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751898AbZCWNJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 09:09:45 -0400
In-Reply-To: <OF387EC803.F810F72A-ONC1257582.00468C6E-C1257582.00475783@LocalDomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund/Transmode wrote on 23/03/2009 13:59:15:
> 
> Patrick McHardy <kaber@trash.net> wrote on 23/03/2009 13:29:33:
> > Joakim Tjernlund wrote:
> > > Patrick McHardy <kaber@trash.net> wrote on 23/03/2009 13:15:45:
> > >> Joakim Tjernlund wrote:
> > >>> doing a "ping -f -l 3" on my host towards my board on linus tree 
as of 
> > > 
> > >>> Friday results in lots of:
> > >>> nf_conntrack: table full, dropping packet.
> > >>> nf_conntrack: table full, dropping packet.
> > >>> nf_conntrack: table full, dropping packet.
> > >>> __ratelimit: 11 callbacks suppressed
> > >>> nf_conntrack: table full, dropping packet.
> > >>> nf_conntrack: table full, dropping packet.
> > >>> nf_conntrack: table full, dropping packet.
> > >>> nf_conntrack: table full, dropping packet.
> > >>>
> > >>> for ucc_geth on a MPC832x.
> > >>> This really looks strange to me, ideas?
> > >> What does /proc/net/netfilter/nf_conntrack show?
> > > 
> > > There is no /proc/net/netfilter/nf_conntrack. There is a
> > > /proc/net/nf_conntrack though and it is empty. If I telnet
> > > to the board I see:
> > 
> > That means that something is leaking conntrack references, most likely
> > by leaking skbs. Since I haven't seen any other reports, my guess 
would
> > be the ucc_geth driver.

> hmm, I cannot see what in the ucc_geth driver is possibly "leaking". One 
thing
> I do notice is that the board becomes almost unresponsive during the 
ping flood.
> Perhaps it is building up a backlog of conntracks during the ping flood?
> 
>  Jocke

next hmm, ethtool -S eth0 shows:
...
 rx-mismatch-drop-frames: 13
...

13 matches the number of lost frames after I stop the ping flood.

The MPC832x manual says this(if i found the correct counter):

REBASE+2C MisMatchDrop 32 Counts number of frames dropped due to MAC 
filtering process, (e.g.
                          Address Mismatch, Type mismatch) and that would 
otherwise
                          considered good frame that would be transferred 
to upper layers

Why would a ping flood result in Address Mismatch or Type mismatch?

Leo?

  Jocke
