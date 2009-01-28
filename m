From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Wed, 28 Jan 2009 11:05:14 -0800
Message-ID: <20090128110514.2191c7a8@extreme>
References: <497EF9AC.70104@poczta.onet.pl>
	<adawscgwbkj.fsf@cisco.com>
	<20090127.160750.120120703.davem@davemloft.net>
	<adaljsvwbkm.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, aluno3@poczta.onet.pl,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55500 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272AbZA1TFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jan 2009 14:05:17 -0500
In-Reply-To: <adaljsvwbkm.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jan 2009 10:05:29 -0800
Roland Dreier <rdreier@cisco.com> wrote:

>  > > but actually I still don't see how it's safe for a net driver to
>  > > call skb_linearize() from its transmit routine, since there's a
>  > > chance that that will unconditionally enable BHs?
>  > 
>  > It's simply not allowed.
>  > 
>  > dev_queue_xmit() at a higher level can do __skb_linearize()
>  > because it does so before doing the rcu_read_lock_bh().
> 
> OK, thanks... what confused me is that several other drivers also do
> skb_linearize() in their hard_start_xmit method... eg bnx2x,
> via-velocity, mv643xx_eth.  So there are several other lurking bugs to
> deal with here I guess.
> 
>  - R.

They all look like lurking (and untested) bug paths. mv643xx is especially
bad since it can leak skb. But it should be possible to call pull_tail
if bh is disabled (as long as irqs are enabled).
