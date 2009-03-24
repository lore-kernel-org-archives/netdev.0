From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] conntrack: Reduce conntrack count in	nf_conntrack_free()
Date: Tue, 24 Mar 2009 19:29:03 +0100
Message-ID: <OFD3FEDA47.35EA7C76-ONC1257583.00655DA0-C1257583.00658959@transmode.se>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>
	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>
	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>
	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>
	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>
	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: avorontsov@ru.mvista.com, Eric Dumazet <dada1@cosmosbay.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:33409 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755496AbZCXS3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 14:29:08 -0400
In-Reply-To: <1237907850.12351.80.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxime Bizon <mbizon@freebox.fr> wrote on 24/03/2009 16:17:30:
> 
> 
> On Tue, 2009-03-24 at 13:07 +0100, Eric Dumazet wrote:
> 
> Hi Eric,
> 
> > We use RCU to defer freeing of conntrack structures. In DOS situation,
> > RCU might accumulate about 10.000 elements per CPU in its internal
> > queues. To get accurate conntrack counts (at the expense of slightly
> > more RAM used), we might consider conntrack counter not taking into
> > account "about to be freed elements, waiting in RCU queues". We thus
> > decrement it in nf_conntrack_free(), not in the RCU callback.
> 
> Your patch fixes the problem on my board too (embedded mips router
> 250Mhz), thanks.
> 
> Yet I'm concerned about what you said concerning RAM usage. I have a
> very small amount on memory left on my board (less than 4M), and I tuned
> ip route cache size and nf_conntrack_max to make sure I won't go OOM.
> 
> With your patch, does it mean 10000 conntrack entries can be allocated
> while nf_conntrack_max is say only 2048 ?

Just add "rcuclassic.qhimark=2048" to your cmdline.

 Jocke

