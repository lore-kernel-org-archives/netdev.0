From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 00/13] Swap-over-NBD without deadlocking
Date: Tue, 26 Apr 2011 16:50:49 +0200
Message-ID: <1303829449.20212.285.camel@twins>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
	 <1303827785.20212.266.camel@twins>  <20110426144635.GK4658@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
 Neil Brown <neilb@suse.de>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110426144635.GK4658@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-04-26 at 15:46 +0100, Mel Gorman wrote:
>=20
> I did find that only a few route-cache entries should be required. In
> the original patches I worked with, there was a reservation for the
> maximum possible number of route-cache entries. I thought this was
> overkill and instead reserved 1-per-active-swapfile-backed-by-NFS.

Right, so the thing I was worried about was a route-cache poison attack
where someone would spam the machine such that it would create a lot of
route cache entries and might flush the one we needed just as we needed
it.

Pinning the one entry we need would solve that (if possible).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
