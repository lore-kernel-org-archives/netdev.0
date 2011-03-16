From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Wed, 16 Mar 2011 14:52:47 -0400
Message-ID: <AANLkTim5FENKBRUcvTUp7=R7x3cWT8veBKKFtxgcKN7V@mail.gmail.com>
References: <1299894051-13820-1-git-send-email-ycheng@google.com>
	<201103151107.35379.carsten@wolffcarsten.de>
	<AANLkTinzkJKb9EtOys2EOW8SDnORdEOT=+UMNBACTJJe@mail.gmail.com>
	<201103161718.39110.carsten@wolffcarsten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>,
	netdev@vger.kernel.org,
	Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
To: Carsten Wolff <carsten@wolffcarsten.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38841 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154Ab1CPSws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 14:52:48 -0400
Received: by yxs7 with SMTP id 7so794160yxs.19
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2011 11:52:47 -0700 (PDT)
In-Reply-To: <201103161718.39110.carsten@wolffcarsten.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2011 at 12:18 PM, Carsten Wolff <carsten@wolffcarsten.de> wrote:
> Unfortunately, no. ;-) My point is, that cwnd should be moderated when the
> congestion state changes are undone after a spurious recovery has been
> detected. Reordering is only one possible reason for a false recovery. And I
> stick to that point because of the thoughts I pointed out in my mail to john,
> i.e. undo typically leading to exceptionally large segment bursts.

There's a more general discussion here as to how much it's worth
avoiding bursts at all.  What research on the subject I'm aware of is
somewhat inconclusive.  It's possible to construct scenarios where
bursting, burst suppression, or pacing each win or lose badly.  If you
can choose only one approach as one-size-fits all it's difficult with
the information at hand to pick only one.  However, I really do wonder
why it's so important to suppress bursts on congestion state undo when
other, likely far more common, sources of bursts are not suppressed.

Carsten, do you have any specific examples of cases you're concerned
about?  FWIW, there are exactly two causes for spurious retransmits:
spurious fast retransmit due to reordering, and spurious timeouts due
to a delay spike.  Are you particularly concerned with one more than
the other?

Thanks,
  -John
