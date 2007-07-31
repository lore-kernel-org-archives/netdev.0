From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6 2/2] [TCP]: Bidir flow must not disregard SACK
 blocks for lost marking
Date: Tue, 31 Jul 2007 08:33:20 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707310759160.15079@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0707302019110.8788@kivilampi-30.cs.helsinki.fi>
 <20070730.195346.124870288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-118250773-1185858485=:15079"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44652 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbXGaFdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 01:33:22 -0400
In-Reply-To: <20070730.195346.124870288.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0707310830470.15079@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-118250773-1185858485=:15079
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0707310808311.15079@kivilampi-30.cs.helsinki.fi>

On Mon, 30 Jul 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 30 Jul 2007 20:19:40 +0300 (EEST)
> 
> > I'm not completely pleased with this solution because readability
> > of the code is somewhat questionable as 'is_dupack' in SACK case
> > is no longer about dupacks only but would mean something like
> > 'lost_marker_work_todo' too... But because of Eifel stuff done
> > in CA_Recovery, the FLAG_DATA_SACKED check cannot be placed to
> > the if statement which seems attractive solution. Nevertheless,
> > I didn't like adding another variable just for that either... :-)
> 
> I don't mind the complex conditionals so much in loss
> handling, they are almost inevitable. However I believe
> they could be simplified as a lot of pieces of code ask
> similar if not identical questions.
>
> We could ask several of these things up-front, regardless
> of path we will take (reno, DSACK, reorder, FRTO, etc.)
> and pass the answers along in a bitmask.  We do that to
> some extent already with how we analyze the retransmit
> queue at the beginning of ACK processing.

That's true, ...and my thought too as I was thinking of
adding FLAG_SND_UNA_ADVANCED (!= FLAG_DATA_ACKED) (or it's
opposite as I haven't yet checked which way it is more
useful). That could help in many places and probably reduces
compare pressure here and there as the bitmask operation
can be done in one compare where it now has to do two
compares, one for snd_una and other for the flag.

...I'll keep an eye on other possible bits too... :-)

-- 
 i.
---696243703-118250773-1185858485=:15079--
