From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6.25] [TCP]: Move FRTO checks out from write queue
 abstraction funcs
Date: Fri, 23 Nov 2007 16:14:03 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711231601490.7738@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0711231422500.24866@kivilampi-30.cs.helsinki.fi>
 <20071123133428.GK18862@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1636456764-1195827243=:7738"
Cc: Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56191 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbXKWOOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 09:14:08 -0500
In-Reply-To: <20071123133428.GK18862@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1636456764-1195827243=:7738
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 23 Nov 2007, Herbert Xu wrote:

> On Fri, Nov 23, 2007 at 02:25:08PM +0200, Ilpo Järvinen wrote:
> > 
> > Better place exists in update_send_head (other non-queue related
> > adjustments are done there as well) which is the only caller of
> > tcp_advance_send_head (now that the bogus call from mtu_probe is
> > gone).
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Hmm, why don't we just get rid of tcp_advance_send_head?
> Or are you planning to start using it again?

The purpose of the tcp_advance_send_head & friends was/is to abstract
the write queue from the TCP worker code. RB-tree wq can then be put in 
place more easily (and I'm hopefully coming to that soon). There are some 
other similar functions in tcp.h as well which currently have only a 
single caller. Please don't undo that work while DaveM is away for a short 
while :-).

IMHO it was a mistake from my side to add frto code into the wq abstaction 
function in the first place though I could use the bogus call that 
tcp_mtu_probe used to make there as an excuse :-), the TCP worker code is 
much better place for it (and it does similar stuff already)...


-- 
 i.
---696243703-1636456764-1195827243=:7738--
