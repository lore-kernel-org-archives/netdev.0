From: Florian Westphal <fw@strlen.de>
Subject: Re: (ipt_log_packet, sb_add) 3.6.0-rc2 kernel panic - not syncing;
 Fatal exception in interrupt
Date: Sun, 2 Sep 2012 15:28:34 +0200
Message-ID: <20120902132834.GB7456@breakpoint.cc>
References: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>
 <20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Sami Farin <hvtaifwkbgefbaei@gmail.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46562 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755940Ab2IBN2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 09:28:35 -0400
Content-Disposition: inline
In-Reply-To: <20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sami Farin <hvtaifwkbgefbaei@gmail.com> wrote:
> I get this panic every 1-2 days.
> Also with 7a611e69b26069a511d9d5251c6a28af6c521121 (commit before 3.6.0-rc4).

Could you please post iptables-save output?
My guess is you're using NFLOG in INPUT?

If so, I bet its caused by the tcp early demux stuff.
Does that crash go away with ip_early_demux sysctl off?

My guess is its assigning skb->sk with TIMEWAIT sockets, which
would explain the crash.
