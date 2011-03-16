From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Wed, 16 Mar 2011 22:24:42 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1103162223330.10688@melkinpaasi.cs.helsinki.fi>
References: <1299894051-13820-1-git-send-email-ycheng@google.com> <201103151107.35379.carsten@wolffcarsten.de> <AANLkTinzkJKb9EtOys2EOW8SDnORdEOT=+UMNBACTJJe@mail.gmail.com> <201103161718.39110.carsten@wolffcarsten.de>
 <AANLkTim5FENKBRUcvTUp7=R7x3cWT8veBKKFtxgcKN7V@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Carsten Wolff <carsten@wolffcarsten.de>,
	Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37229 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952Ab1CPUYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 16:24:43 -0400
In-Reply-To: <AANLkTim5FENKBRUcvTUp7=R7x3cWT8veBKKFtxgcKN7V@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Mar 2011, John Heffner wrote:

> On Wed, Mar 16, 2011 at 12:18 PM, Carsten Wolff <carsten@wolffcarsten.de> wrote:
> > Unfortunately, no. ;-) My point is, that cwnd should be moderated when the
> > congestion state changes are undone after a spurious recovery has been
> > detected. Reordering is only one possible reason for a false recovery. And I
> > stick to that point because of the thoughts I pointed out in my mail to john,
> > i.e. undo typically leading to exceptionally large segment bursts.
> 
> There's a more general discussion here as to how much it's worth
> avoiding bursts at all.  What research on the subject I'm aware of is
> somewhat inconclusive.  It's possible to construct scenarios where
> bursting, burst suppression, or pacing each win or lose badly.  If you
> can choose only one approach as one-size-fits all it's difficult with
> the information at hand to pick only one.  However, I really do wonder
> why it's so important to suppress bursts on congestion state undo when
> other, likely far more common, sources of bursts are not suppressed.
> 
> Carsten, do you have any specific examples of cases you're concerned
> about?  FWIW, there are exactly two causes for spurious retransmits:
> spurious fast retransmit due to reordering, and spurious timeouts due
> to a delay spike.  Are you particularly concerned with one more than
> the other?

The latter is handled with FRTO (defaults on in Linux) so nicely that no 
burstiness can be seen.

-- 
 i.
