From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [RFC] [TCP]: Catch skb with S+L bugs earlier
Date: Mon, 30 Apr 2007 10:42:38 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704301037080.29336@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0703281650150.27182@kivilampi-30.cs.helsinki.fi>
 <20070430.002837.27783394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1358795498-1177918958=:29336"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46353 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423130AbXD3Hml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:42:41 -0400
In-Reply-To: <20070430.002837.27783394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1358795498-1177918958=:29336
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 30 Apr 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 28 Mar 2007 17:02:47 +0300 (EEST)
> 
> > SACKED_ACKED and LOST are mutually exclusive, thus this
> > condition is bug with SACK (IMHO). NewReno, however, could get
> > enough duplicate ACKs which increment sacked_out, so it makes
> > sense to do this kind of limitting for non-SACK TCP but not for
> > SACK-enabled one. Perhaps the author had that in mind but did
> > the logic accidently wrong way around?
> > 
> > Eventually these bugs trigger traps in the tcp_clean_rtx_queue
> > but it's much more informative to do this here (excludes some
> > other possible bugs).
> > 
> > Maybe this BUG_TRAP is too expensive to be included everywhere
> > in the TCP code. Should there be some #if to surround it?
> > 
> > Compile tested. Sadly enough I don't have time for couple of
> > weeks to test this as it would require some setuping, and besides,
> > my test machines are occupied currently to other work, but this 
> > might also be net-2.6 (or even stable) material if it really
> > works (feel free to cut this paragraph or part of it if you
> > decide to include this :-)).
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> I've applied this, thanks for your patience.
> 
> I will see if it makes my workstation explode :-)

I think I sent an updated version later (hopefully I reach you before 
you push these out :-)), which made the BUG_ON unconditional (I used it 
instead of BUG_TRAP as it seems to be generic machinery for handling 
these).

Mine didn't explode (neither with SACK nor without it)... :-) With 
SACK it's very clearly a BUG that must never happen (non-SACK seems safe 
but I haven't tested e.g. all those fragmentation/collapse paths).

-- 
 i.
---696243703-1358795498-1177918958=:29336--
