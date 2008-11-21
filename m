From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fix potential corner case issue in segmentation
 (Was: Re: [PATCH] Do not use TSO/GSO when there is urgent data)
Date: Fri, 21 Nov 2008 20:21:07 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811212019080.9953@wrl-59.cs.helsinki.fi>
References: <200811211319.45515.ptesarik@suse.cz>
 <Pine.LNX.4.64.0811211438420.3930@wrl-59.cs.helsinki.fi>
 <200811211651.52024.ptesarik@suse.cz> <Pine.LNX.4.64.0811211901120.9953@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696208474-887022033-1227287286=:9953"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Jan =?utf-8?q?=C5=A0embera?=" <jsembera@suse.cz>
To: Petr Tesarik <ptesarik@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44439 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091AbYKUSVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 13:21:10 -0500
In-Reply-To: <Pine.LNX.4.64.0811211901120.9953@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0811212019081.9953@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-887022033-1227287286=:9953
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0811211908151.9953@wrl-59.cs.helsinki.fi>

On Fri, 21 Nov 2008, Ilpo Järvinen wrote:

> On Fri, 21 Nov 2008, Petr Tesarik wrote:
> 
> > > It's a bit intrusive but I couldn't immediately come up with alternative
> > > that would have worked (came up with some not working ones :-)).
> > 
> > Yes, I also noticed that. We could add some more code to tcp_mark_urg(), e.g. 
> > walk sk_write_queue and adjust the pending SKBs there...
> >
> > Is it OK to simply set all skb->gso_segs to zero, and let the next call to 
> > tcp_init_tso_segs redo them?
> 
> If we walk backwards we could consider short-circuit the walk at 16-bit 
> urg field limit. I wouldn't mind if users of such obscure feature pay the 
> price but the final decision is up to Dave of course.

On second though, it won't work since those fields get initialized later, 
ie., at the send time so it would undo the effort.

-- 
 i.
---696208474-887022033-1227287286=:9953--
