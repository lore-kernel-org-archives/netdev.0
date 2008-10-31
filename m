From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tbench wrt. loopback TSO
Date: Fri, 31 Oct 2008 11:16:21 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810311106140.7072@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810271704530.7072@wrl-59.cs.helsinki.fi>
 <20081027170314.GA25148@ioremap.net> <Pine.LNX.4.64.0810272113280.13973@wrl-59.cs.helsinki.fi>
 <20081031.011411.238617852.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1039050330-1225444581=:7072"
Cc: zbr@ioremap.net, Netdev <netdev@vger.kernel.org>, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56998 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453AbYJaJQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 05:16:28 -0400
In-Reply-To: <20081031.011411.238617852.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1039050330-1225444581=:7072
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 31 Oct 2008, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 28 Oct 2008 00:17:00 +0200 (EET)
> 
> > > Another modulo sits in tcp_mss_split_point().
> > 
> > I know it's there but it should occur not that often.
> 
> It happens every sendmsg() call, and all tbench does is small send,
> small recv, repeat.

This is not true for the mss_split_point case which I was speaking of, I 
even explained this in the part following that first sentence which you 
choose to snip away:

If you have pcount == 1 (len <= mss implies that) that won't even execute 
and rest of the cases involve handling rwin limited & nagle. I suppose we 
could make nagle to work without splitting the skb to sub-mss (needs some 
auditting to find out if something else than snd_sml setting assumes 
skb->len < mss, nagle check probably as well but I don't remember w/o 
looking).

To reiterate, with small send you have pcount == 1 and that won't execute 
any of the mss_split_point code!

The tcp_current_mss code is a different beast (if you meant that, I 
didn't :-)), yes it executes every so often but I was under impression 
that we agreed on it already. :-)

> So with TSO on, a small increase in performance is no surprise, as
> we will save some cycles often enough.

Also tcp_send_fin seems to do tcp_current_mss(sk, 1) so it's at least two 
modulos per transaction...

-- 
 i.
---696208474-1039050330-1225444581=:7072--
