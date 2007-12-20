From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Thu, 20 Dec 2007 23:05:56 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712202247410.20288@kivilampi-30.cs.helsinki.fi>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
 <4768123A.7040603@cosmosbay.com>  <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
  <47682F8C.20205@cosmosbay.com>  <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
  <47694FCC.1020507@cosmosbay.com>  <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
  <Pine.LNX.4.64.0712191857270.12329@fbirervta.pbzchgretzou.qr>
 <1198161695.6154.47.camel@andromache> <83a51e120712200837p9e3d1a4g15b5f4763597073e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Glen Turner <gdt@gdt.id.au>,
	Jan Engelhardt <jengelh@computergmbh.de>,
	Eric Dumazet <dada1@cosmosbay.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Nichols <jamesnichols3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51555 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601AbXLTVF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 16:05:58 -0500
In-Reply-To: <83a51e120712200837p9e3d1a4g15b5f4763597073e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2007, James Nichols wrote:

> > You'd probably should also investigate the Linux kernel,
> > especially the size and locks of the components of the Sack data
> > structures and what happens to those data structures after Sack is
> > disabled (presumably the Sack data structure is in some unhappy
> > circumstance, and disabling Sack allows the data to be discarded,
> > magically unclaging the box).

...Not sure if you want now to invent such structure. Yes, we have per skb 
->sacked but again in SYN_SENT there are very few things who touch it at 
all, and they just set it to zero (though it would not even be mandatory 
for tcp_transmit_skb, IIRC, checked that just couple of days ago due to 
other things).

Another thing is the rx_opt.sack_ok which is just couple flag bits that 
tell the TCP variant in use (and it's mostly used only after SYN handshake 
completes). The rest (the actual SACK blocks) is in the ack_skb but again 
it has very little meaning in SYN_SENT state unless somebody is crazy 
enough to add SACK blocks to SYN-ACKs :-).

> > In the absence of the reporter wanting to dump the kernel's
> > core, how about a patch to print the Sack datastructure when
> > the command to disable Sack is received by the kernel?
> > Maybe just print the last 16b of the IP address?
> 
> Given the fact that I've had this problem for so long, over a variety
> of networking hardware vendors and colo-facilities, this really sounds
> good to me.  It will be challenging for me to justify a kernel core
> dump, but a simple patch to dump the Sack data would be do-able.

If your symptoms really are: SYNs leaving (if they show up in tcpdump, for 
sure they've left TCP code already) and SYN-ACK not showing up even in 
something as early as in tcpdump (for sure TCP side code didn't execute at 
that point yet), there's very little change that Linux' TCP code has some 
bug in it, only things that do something in such scenario are the SYN 
generation and retransmitting SYNs (and those are trivially verifiable 
from tcpdump).


-- 
 i.
