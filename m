From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Wed, 4 Jun 2008 10:12:04 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806040943120.16057@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0805241156120.27780@wrl-59.cs.helsinki.fi>
 <cf4145200805240706p2eb54e9ei51bc33f782ff5aef@mail.gmail.com>
 <Pine.LNX.4.64.0805261349510.16829@wrl-59.cs.helsinki.fi>
 <20080603.163518.153888925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1020273978-1212563524=:16057"
Cc: brian.vowell@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58362 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbYFDHMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 03:12:09 -0400
In-Reply-To: <20080603.163518.153888925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1020273978-1212563524=:16057
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 3 Jun 2008, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 26 May 2008 14:24:33 +0300 (EEST)
> 
> Ilpo, do you want me to apply this to net-2.6?

Yes thanks, it is necessary to keep the state consistent (it also explains 
some .22/23 time left_out warn_ons too which were mysterious back then).
Also -stable (I guess it would be necessary to almost any older stable
too though some older ones might want to sync left_out on that same place 
too).

It was nice that this path was also triggered while running the TCP 
debug patch (I haven't gotten a one in here), otherwise we would never
have known though I started to suspect that such path existed once I
tried to analyze those left_out problems (before it got dropped 
altogether), but I just couldn't find the problem because it lies on 
such "error path" which was too easy to overlook.

I also finally have found the cause to the !sacked_out && fackets_out
trap :-). ...I'll post the fix to that later today to relevant parties.

> > [PATCH] [TCP]: Fix inconsistency source (CA_Open only when !tcp_left_out(tp))


-- 
 i.
---696208474-1020273978-1212563524=:16057--
