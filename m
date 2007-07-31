From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6 1/2] [TCP]: Fix ratehalving with bidirectional
 flows
Date: Tue, 31 Jul 2007 07:59:10 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707310751260.15079@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0707302017290.8788@kivilampi-30.cs.helsinki.fi>
 <20070730.194946.08653937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-531100968-1185857806=:15079"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44020 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757644AbXGaE7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 00:59:12 -0400
In-Reply-To: <20070730.194946.08653937.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0707310757080.15079@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-531100968-1185857806=:15079
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0707310757081.15079@kivilampi-30.cs.helsinki.fi>

On Mon, 30 Jul 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 30 Jul 2007 20:18:45 +0300 (EEST)
> 
> > Actually, the ratehalving seems to work too well, as cwnd is
> > reduced on every second ACK even though the packets in flight
> > remains unchanged. Recoveries in a bidirectional flows suffer
> > quite badly because of this, both NewReno and SACK are affected.
> > 
> > After this patch, rate halving is performed for ACK only if
> > packets in flight was supposedly changed too.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> This fix looks great, and I see no potential problems with
> Reno after doing a bit of auditing.
> 
> Applied and I'll push to -stable too.

I think it's probably good to add tp->snd_una != prior_snd_una
check there too... It's not going to make a large difference,
mostly just to be conservative when skb collapse stuff got done
(and maybe to annoy cheaters too though I couldn't at this point
figure out how they could abuse it)...

...I think I can come up with that on Wednesday, so please hold
stable push until that.

-- 
 i.
---696243703-531100968-1185857806=:15079--
