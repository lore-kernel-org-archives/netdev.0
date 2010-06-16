From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next-2.6] syncookies: check decoded options against
 sysctl settings
Date: Wed, 16 Jun 2010 10:03:09 +0200
Message-ID: <20100616080309.GC20287@Chamillionaire.breakpoint.cc>
References: <1276464875-4460-1-git-send-email-fw@strlen.de>
 <20100615.180947.241927235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:50686 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751555Ab0FPIDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 04:03:11 -0400
Content-Disposition: inline
In-Reply-To: <20100615.180947.241927235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sun, 13 Jun 2010 23:34:35 +0200
> 
> > -	if (tcp_opt->sack_ok)
> > -		tcp_sack_reset(tcp_opt);
> > +	if (tcp_opt->sack_ok && !sysctl_tcp_sack)
> > +		return false;
> >  
> 
> If you remove the tcp_sack_reset() call here, who is going to
> do it?

Right, I should have mentioned that in the changelog, sorry about that.

Bottom line is that I failed to find out why its needed.
Both call sites of this function (cookie_v4_check, cookie_v6_check)
allocate the "struct tcp_options_received" argument on the stack, zero it,
hand it to tcp_parse_options() and then call cookie_check_timestamp().

I did not find any place in tcp_parse_options that would cause
tcp_opt->num_sacks/dsack to become nonzero.

Even if it can turn nonzero, I do not see any ill effects that might
happen then. The structure is on the stack and after tcp_parse_options()
returns only a few selected members are copied to the inet_request_sock.
