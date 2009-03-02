From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-next 14/17] tcp: remove pointless .dsack code
Date: Mon, 2 Mar 2009 13:54:17 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0903021340540.31742@wrl-59.cs.helsinki.fi>
References: <12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831019-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20090302.030320.95493086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1780423684-1235994857=:31742"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45544 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbZCBLyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 06:54:21 -0500
In-Reply-To: <20090302.030320.95493086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1780423684-1235994857=:31742
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 2 Mar 2009, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sat, 28 Feb 2009 16:44:39 +0200
> 
> > From: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > 
> > In the pure assignment case, the earlier zeroing is
> > still in effect.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> I skipped this one.
> 
> These tests could be there to avoid dirtying a cacheline
> when unnecessary.  And so unless we can prove the condition
> always hits and we always do the write, we should keep
> the tests there.

We'll be dirty it anyway (not that I check), the first "real" statement
in tcp_rcv_established is:

	tp->rx_opt.saw_tstamp = 0;

...that'll land on the same dword. :-/

I suppose the blocks are there just because they had more complexity 
inside when they had to calculate the eff_sacks too (maybe it would
have been better to just remove them in that drop-patch so you would
have had less head-ache :-)).

Besides, it isn't very nice to have tx/rx or rx'es on different cpus 
anyway, no? 


-- 
 i.
---696208474-1780423684-1235994857=:31742--
