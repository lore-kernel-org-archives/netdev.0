From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [BUG?] tcp: potential bug in tcp_is_sackblock_valid()
Date: Fri, 9 Sep 2011 11:03:58 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1109091050550.11963@melkinpaasi.cs.helsinki.fi>
References: <4E696FD0.7060702@intel.com> <20110909015429.GA9156@gondor.apana.org.au> <4E6975B2.8000603@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38900 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758118Ab1IIIEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 04:04:00 -0400
In-Reply-To: <4E6975B2.8000603@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Sep 2011, Yan, Zheng wrote:

> On 09/09/2011 09:54 AM, Herbert Xu wrote:
> > On Fri, Sep 09, 2011 at 09:45:52AM +0800, Yan, Zheng wrote:
> >> I found a check in tcp_is_sackblock_valid() is suspicious. It against
> >> its comment and RFC. I think the correct check should be:
> >> ---
> >> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> >> index 385c470..a5d01b1 100644
> >> --- a/net/ipv4/tcp_input.c
> >> +++ b/net/ipv4/tcp_input.c
> >> @@ -1124,7 +1124,7 @@ static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
> >>                 return 0;
> >>  
> >>         /* ...Then it's D-SACK, and must reside below snd_una completely */
> >> -       if (!after(end_seq, tp->snd_una))
> >> +       if (after(end_seq, tp->snd_una))
> >>                 return 0;
> >>  
> >>         if (!before(start_seq, tp->undo_marker))
> >> ---
> >>
> >> I also checked /proc/net/netstat of my laptop, found TCPDSACKIgnoredOld
> >> field is not zero. Maybe it's caused by the bug.

Hmm, some Ignored I was expecting to see even when nothing was wrong but I 
think it might have been the other counter... too long time already passed 
to remember all the details I've been thinking.

> > Yes this looks like a typo.  Please resend your patch with a
> > description and signed-off-by line.
> 
> I think the bug has a big influence on tcp DSACKs. It's better to
> leave it to people who fully understand tcp code.

Indeed, it looks like a double negative error.

-- 
 i.
