From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] tcp: fix undo after RTO for CUBIC
Date: Thu, 19 Jan 2012 18:49:21 -0800
Message-ID: <20120119184921.314d3d88@nehalam.linuxnetplumber.net>
References: <1326944879-22780-1-git-send-email-ncardwell@google.com>
	<1326944879-22780-2-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Jerry Chu <hkchu@google.com>, Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60727 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753037Ab2ATCtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 21:49:24 -0500
In-Reply-To: <1326944879-22780-2-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jan 2012 22:47:59 -0500
Neal Cardwell <ncardwell@google.com> wrote:

> This patch fixes CUBIC so that cwnd reductions made during RTOs can be
> undone (just as they already can be undone when using the default/Reno
> behavior).
> 
> When undoing cwnd reductions, BIC-derived congestion control modules
> were restoring the cwnd from last_max_cwnd. There were two problems
> with using last_max_cwnd to restore a cwnd during undo:
> 
> (a) last_max_cwnd was set to 0 on state transitions into TCP_CA_Loss
> (by calling the module's reset() functions), so cwnd reductions from
> RTOs could not be undone.
> 
> (b) when fast_covergence is enabled (which it is by default)
> last_max_cwnd does not actually hold the value of snd_cwnd before the
> loss; instead, it holds a scaled-down version of snd_cwnd.
> 
> This patch makes the following changes:
> 
> (1) upon undo, revert snd_cwnd to ca->loss_cwnd, which is already, as
> the existing comment notes, the "congestion window at last loss"
> 
> (2) stop forgetting ca->loss_cwnd on TCP_CA_Loss events
> 
> (3) use ca->last_max_cwnd to check if we're in slow start
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

I was unsure of this, so forwarded it to the author 
and received his confirmation.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Sangtae Ha <sangtae.ha@gmail.com>
