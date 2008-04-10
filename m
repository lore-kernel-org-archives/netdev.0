From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Thu, 10 Apr 2008 09:36:52 +0200
Message-ID: <20080410073652.GC10019@one.firstfloor.org>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr> <873apwrc4t.fsf@basil.nowhere.org> <7i3apwbblk.fsf@lanthane.pps.jussieu.fr> <20080408163252.GS16647@one.firstfloor.org> <7iwsn8s107.fsf@lanthane.pps.jussieu.fr> <20080408175353.GA17147@one.firstfloor.org> <7ik5j7ghgh.fsf@lanthane.pps.jussieu.fr> <20080409174954.GD30885@one.firstfloor.org> <47FD6C0E.7040808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55104 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbYDJHcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 03:32:19 -0400
Content-Disposition: inline
In-Reply-To: <47FD6C0E.7040808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well, if I'm not mistaken net_random() used to be a function
> (in net/core/utils.c) that didn't have this problem. 

Correct it's a regression.

> So these
> problems seem to have been introduced by the conversion to
> srandom().

I think the per CPU ness was generally a mistake, it was a misguided
optimization and hurts

Iff someone really needs per cpu RNDs the better way would have been
to add a rand_r() like interface with explicit state and only do 
that in that particular caller.

Also I think a lot of get_random_bytes() shouldn't really be using it 
because they don't need precious cryptographically strong entropy,
but rather should get their data from another RND which has been
seeded once from the entropy pool only.

-Andi
