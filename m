From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Sun, 27 May 2007 10:58:27 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070526.164418.115928217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1835166717-1180251599=:2532"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37713 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbXE0H63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 03:58:29 -0400
In-Reply-To: <20070526.164418.115928217.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0705271042030.2532@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1835166717-1180251599=:2532
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0705271042031.2532@kivilampi-30.cs.helsinki.fi>

On Sat, 26 May 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sat, 26 May 2007 11:35:53 +0300
> 
> > Dave, you could consider applying other than the last one if they
> > seem ok to you too (you'll need to rebase your tcp-2.6 in that case
> > first to apply cleanly those that touch tcp_sync_left_out :-)).
> 
> Absolutely, I'll do the quick rebase of tcp-2.6 and review +
> applying of your patches (except the last one) over the weekend.

While you're in the right context (reviewing patch 8), you could also
look if tcp_clean_rtx_queue does a right thing when passing a strange 
pkts_acked to congestion control modules. I wonder if it really should 
ignore GSO the way it does currently... I read some cc module code and 
some was adding it to snd_cwnd_cnt, etc. which is a strong indication 
that GSO should be considered... Also if the head is GSO skb that is not 
completely acked, the loop breaks with pkts_acked being zero, I doubt
that can be correct... 

...added Stephen H. & Herbert X. to this thread since also they might have 
some idea about it.

...Anyway, if it's wrong, the fix should go to net-2.6 rather than to 
tcp-2.6...


-- 
 i.
---696243703-1835166717-1180251599=:2532--
