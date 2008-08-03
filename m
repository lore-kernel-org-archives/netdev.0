From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Sat, 02 Aug 2008 23:56:40 -0700 (PDT)
Message-ID: <20080802.235640.250921883.davem@davemloft.net>
References: <489322A9.3080906@hp.com>
	<20080802003016.GA24295@gondor.apana.org.au>
	<4894ED25.6040200@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47306
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752091AbYHCG4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 02:56:40 -0400
In-Reply-To: <4894ED25.6040200@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Sat, 02 Aug 2008 19:26:29 -0400

> Herbert Xu wrote:
> > On Fri, Aug 01, 2008 at 10:50:17AM -0400, Vlad Yasevich wrote:
> >>> +	inet->pmtudisc = transport->param_flags & SPP_PMTUD_ENABLE ?
> >>> +			 IP_PMTUDISC_DO : IP_PMTUDISC_DONT;
> >> If you insist on doing this, you need to save the old value and restore
> >> it after ip_queue_xmit(). 
> >>
> >> The reason is that PMTU discovery change on a specific transport or
> >> association should not affect the socket, since there could be multiple
> >> associations on a given socket.  Each association has it's own control.
> > 
> > Yes but they'll all pass through here so it'll get set to the
> > appropriate value.
> > 
> > Cheers,
> 
> OK, I see what you mean.  Let me run some tests with this patch.  I doesn't
> look like it will cause any issues, but I'd like to verify.

Like Herbert said, thanks for doing this testing.

Let me know how it goes so I can apply the patch if everything
is OK.
