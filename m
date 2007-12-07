From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC] TCP illinois max rtt aging
Date: Fri, 7 Dec 2007 15:05:59 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712071442530.18529@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712041031110.18529@kivilampi-30.cs.helsinki.fi>
 <aa7d2c6d0712061927g2e6f1679o8b05f76d723c0c76@mail.gmail.com>
 <Pine.LNX.4.64.0712071254070.18529@kivilampi-30.cs.helsinki.fi>
 <20071207.044150.02925935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1703991477-1197032759=:18529"
Cc: lachlan.andrew@gmail.com, Netdev <netdev@vger.kernel.org>,
	quetchen@caltech.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34441 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbXLGNGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 08:06:04 -0500
In-Reply-To: <20071207.044150.02925935.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1703991477-1197032759=:18529
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 7 Dec 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Fri, 7 Dec 2007 13:05:46 +0200 (EET)
> 
> > I guess if you get a large cumulative ACK, the amount of processing is 
> > still overwhelming (added DaveM if he has some idea how to combat it).
> > 
> > Even a simple scenario (this isn't anything fancy at all, will occur all 
> > the time): Just one loss => rest skbs grow one by one into a single 
> > very large SACK block (and we do that efficiently for sure) => then the 
> > fast retransmit gets delivered and a cumulative ACK for whole orig_window 
> > arrives => clean_rtx_queue has to do a lot of processing. In this case we 
> > could optimize RB-tree cleanup away (by just blanking it all) but still 
> > getting rid of all those skbs is going to take a larger moment than I'd 
> > like to see.
> > 
> > That tree blanking could be extended to cover anything which ACK more than 
> > half of the tree by just replacing the root (and dealing with potential 
> > recolorization of the root).
> 
> Yes, it's the classic problem.  But it ought to be at least
> partially masked when TSO is in use, because we'll only process
> a handful of SKBs.  The more effectively TSO batches, the
> less work clean_rtx_queue() will do.

No, that's not what is going to happen, TSO won't help at all
because one-by-one SACKs will fragment every single one of them
(see tcp_match_skb_to_sack) :-(. ...So we're back in non-TSO
case, or am I missing something?

> Web100 just provides statistics and other kinds of connection data
> to userspace, all the actual algorithm etc. modifications have been
> merged upstream and yanked out of the web100 patch.  I was looking
> at it the other night and it's frankly totally uninteresting these
> days :-)

...Thanks, I'll keep that in my mind when looking... :-)


-- 
 i.
---696243703-1703991477-1197032759=:18529--
