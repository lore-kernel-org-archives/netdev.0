From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: don't fragment SACKed skbs in
 tcp_mark_head_lost()
Date: Sat, 3 Mar 2012 16:22:01 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1203031621070.7744@melkinpaasi.cs.helsinki.fi>
References: <1330760211-25785-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1950517882-1330784521=:7744"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33372 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254Ab2CCOWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 09:22:04 -0500
In-Reply-To: <1330760211-25785-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1950517882-1330784521=:7744
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 3 Mar 2012, Neal Cardwell wrote:

> In tcp_mark_head_lost() we should not attempt to fragment a SACKed skb
> to mark the first portion as lost. This is for two primary reasons:
> 
> (1) tcp_shifted_skb() coalesces adjacent regions of SACKed skbs. When
> doing this, it preserves the sum of their packet counts in order to
> reflect the real-world dynamics on the wire. But given that skbs can
> have remainders that do not align to MSS boundaries, this packet count
> preservation means that for SACKed skbs there is not necessarily a
> direct linear relationship between tcp_skb_pcount(skb) and
> skb->len. Thus tcp_mark_head_lost()'s previous attempts to fragment
> off and mark as lost a prefix of length (packets - oldcnt)*mss from
> SACKed skbs were leading to occasional failures of the WARN_ON(len >
> skb->len) in tcp_fragment() (which used to be a BUG_ON(); see the
> recent "crash in tcp_fragment" thread on netdev).
> 
> (2) there is no real point in fragmenting off part of a SACKed skb and
> calling tcp_skb_mark_lost() on it, since tcp_skb_mark_lost() is a NOP
> for SACKed skbs.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
 i.
--8323329-1950517882-1330784521=:7744--
