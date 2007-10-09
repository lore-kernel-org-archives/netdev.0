From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: raw PF_PACKET protocol selection
Date: Tue, 09 Oct 2007 09:51:25 +0200
Message-ID: <1191916285.6682.83.camel@gentoo-jocke.transmode.se>
References: <E1If5b3-00043F-00@gondolin.me.apana.org.au>
	 <00ac01c80a3a$cc83a6a0$04ac10ac@Jocke> <20071009071338.GA15057@2ka.mipt.ru>
	 <1191914858.6682.75.camel@gentoo-jocke.transmode.se>
	 <20071009073437.GA1951@2ka.mipt.ru>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:32847 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751606AbXJIHv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 03:51:28 -0400
In-Reply-To: <20071009073437.GA1951@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-09 at 11:34 +0400, Evgeniy Polyakov wrote:
> On Tue, Oct 09, 2007 at 09:27:38AM +0200, Joakim Tjernlund (joakim.tjernlund@transmode.se) wrote:
> > > Did you change eth_type_trans() to catch your proto?
> > > 
> > 
> > Just fond out something:
> > if I redirect my prog like so:
> > ./sniff > log
> > and press Ctrl-C after a packet has been sent to it, 
> > it does NOT work. I don't get ANY output in my "log" file, not
> > even the printf("---------\n") appears.
> > But if I run whithout redirect it works(at least with ETH_P_BPQ)
> > Anyone else see this too?
> 
> I only tested with IP and ARP packets - I can not say when packet was
> actually received and written to log, but it does start filling up, but
> maybe not immediately - it can be output buffering in shell though.

Did you receive many packets? Seems like when I receive just 1 or 2 pkgs
I get the empty log. If I strace ./sniff > log I see that recvfrom gets
pkgs, but there are no trace of writes. I guess this
is a bash(3.2_p17) or glibc(2.5.-r4) bug?
