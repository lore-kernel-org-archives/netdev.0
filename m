From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next-2.6] syncookies: check decoded options
 against sysctl settings
Date: Wed, 16 Jun 2010 14:42:28 -0700 (PDT)
Message-ID: <20100616.144228.246524500.davem@davemloft.net>
References: <20100616211549.GA23419@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55672
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754030Ab0FPVmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 17:42:16 -0400
In-Reply-To: <20100616211549.GA23419@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 16 Jun 2010 23:15:49 +0200

> Discard the ACK if we find options that do not match current sysctl
> settings.
> 
> Previously it was possible to create a connection with sack,
> wscale, etc. enabled even if the feature was disabled via sysctl.
> 
> Also remove an unneeded call to tcp_sack_reset() in
> cookie_check_timestamp:
> Both call sites (cookie_v4_check, cookie_v6_check) zero
> "struct tcp_options_received", hand it to tcp_parse_options()
> (which does not change tcp_opt->num_sacks/dsack) and then call
> cookie_check_timestamp().
> 
> Even if num_sacks/dsacks were changed, the structure is allocated on
> the stack and after cookie_check_timestamp returns only a few selected
> members are copied to the inet_request_sock.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
