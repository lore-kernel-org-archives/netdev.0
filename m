From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 4/4]: Kill fastpath_{skb,cnt}_hint.
Date: Sat, 3 Mar 2007 14:27:46 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703031414220.18827@kivilampi-30.cs.helsinki.fi>
References: <20070228.114949.18302561.davem@davemloft.net>
 <20070301181340.GD25760@galon.ev-en.org> <20070302.222250.41632359.davem@davemloft.net>
 <Pine.LNX.4.64.0703031145110.18827@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-611096408-1172924866=:18827"
Cc: baruch@ev-en.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51332 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965261AbXCCM1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 07:27:47 -0500
In-Reply-To: <Pine.LNX.4.64.0703031145110.18827@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-611096408-1172924866=:18827
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 3 Mar 2007, Ilpo Järvinen wrote:
> On Fri, 2 Mar 2007, David Miller wrote:
> > From: Baruch Even <baruch@ev-en.org>
> > Date: Thu, 1 Mar 2007 20:13:40 +0200
> 
> > > One drawback for this approach is that you now walk the entire sack
> > > block when you advance one packet. If you consider a 10,000 packet queue
> > > which had several losses at the beginning and a large sack block that
> > > advances from the middle to the end you'll walk a lot of packets for
> > > that one last stretch of a sack block.
> 
> Maybe this information in the last ACK could be even used as advantage to 
> speed up the startpoint lookup, since the last ACK very likely contains 
> the highest SACK block (could not hold under attack though), no matter how 
> big it is, and it's not necessary to process it ever if we know for sure 
> that it was the global highest rather than a local one. Using that, it's 
> trivial to find the starting point below the SACK block and that could be 
> passed to the head_lost marking on-the-fly using stack rather than in the
> structs. Sort of fastpath too :-)... Maybe even some auto-tuning thingie 
> which enables conditionally skipping of large SACK-blocks to reuse all of 
> this last ACK information in mark_head but that would get rather 
> complicated I think.

Even better, adding to more the globally highest SACKed block range that 
is already larger than tp->reordering does nothing in mark_head_lost 
unless ca_state or high_seq are also changed (just a quick thoughts, 
it might be possible to exclude also them with careful analysis of state), 
isn't that so? But taking advantage of this might require inter-ACK state 
and be then less useful optimization. So only thing that would remain is 
the check for timedout above the highest SACKed block...

-- 
 i.
---696243703-611096408-1172924866=:18827--
