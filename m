From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Sun, 27 May 2007 14:16:34 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070526.164418.115928217.davem@davemloft.net>
 <Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
 <20070527.021104.74747736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1950891126-1180264594=:2663"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34875 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbXE0LQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 07:16:36 -0400
In-Reply-To: <20070527.021104.74747736.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1950891126-1180264594=:2663
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sun, 27 May 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sun, 27 May 2007 10:58:27 +0300 (EEST)
> 
> > While you're in the right context (reviewing patch 8), you could also
> > look if tcp_clean_rtx_queue does a right thing when passing a strange 
> > pkts_acked to congestion control modules. I wonder if it really should 
> > ignore GSO the way it does currently... I read some cc module code and 
> > some was adding it to snd_cwnd_cnt, etc. which is a strong indication 
> > that GSO should be considered... Also if the head is GSO skb that is not 
> > completely acked, the loop breaks with pkts_acked being zero, I doubt
> > that can be correct... 
> 
> [...snip...]
> will likely take a look at these issues wrt. patch 8 tomorrow.

...I hope I got myself understood correctly (with my non-native
English :-))... ...My intention was to say that there might be
a bug in tcp_clean_rtx_queue too, which on logical level is
unrelated to the patch 8 itself and to the change it makes (but
caught my attention while I was doing that patch as it resides in
the same function). ...There could have been confusion since I'm too 
changing things in the same function and because my article usage is 
usually far from perfect... :-) Also the fastretrans_alert arg rename
to the same name (i.e., pkts_acked) in patch 8 is unrelated to the 
potential bug.

Thus, my original question basically culminates in this: should cc
modules be passed number of packets acked or number of skbs acked?
...The latter makes no sense to me unless the value is intented to
be interpreted as number of timestamps acked or something along those 
lines. ...I briefly tried looking up for documentation for cc module 
interface but didn't find anything useful about this, and thus asked in 
the first place...


-- 
 i.
---696243703-1950891126-1180264594=:2663--
