From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] allow dctcp alpha to drop to zero
Date: Mon, 19 Oct 2015 16:01:35 +0200
Message-ID: <20151019140135.GF4386@breakpoint.cc>
References: <20151019045908.GB11368@mininet-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Glenn Judd <glenn.judd@morganstanley.com>
To: Andrew Shewmaker <agshew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34524 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751063AbbJSOBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 10:01:39 -0400
Content-Disposition: inline
In-Reply-To: <20151019045908.GB11368@mininet-vm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Shewmaker <agshew@gmail.com> wrote:
> If alpha is strictly reduced by alpha >> dctcp_shift_g and if alpha is less
> than 1 << dctcp_shift_g, then alpha may never reach zero. For example,
> given shift_g=4 and alpha=15, alpha >> dctcp_shift_g yields 0 and alpha
> remains 15. The effect isn't noticeable in this case below cwnd=137, but
> could gradually drive uncongested flows with leftover alpha down to
> cwnd=137. A larger dctcp_shift_g would have a greater effect.
> 
> This change causes alpha=15 to drop to 0 instead of being decrementing by 1
> as it would when alpha=16. However, it requires one less conditional to
> implement since it doesn't have to guard against subtracting 1 from 0U. A
> decay of 15 is not unreasonable since an equal or greater amount occurs at
> alpha >= 240.
> 
> Signed-off-by: Andrew G. Shewmaker <agshew@gmail.com>

Acked-by: Florian Westphal <fw@strlen.de>

[ cwnd=137 is quite large so I don't think its important enough for
-stable ].
