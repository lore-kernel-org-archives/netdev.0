From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipv4: use next hop exceptions also for input
 routes
Date: Thu, 27 Jun 2013 11:52:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306271146550.2436@ja.ssi.bg>
References: <1372318025-7634-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="280144257-1976251345-1372323135=:2436"
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Timo_Ter=C3=A4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55706 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752760Ab3F0Iqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 04:46:44 -0400
In-Reply-To: <1372318025-7634-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--280144257-1976251345-1372323135=:2436
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Thu, 27 Jun 2013, Timo Teräs wrote:

> Commit d2d68ba9 (ipv4: Cache input routes in fib_info nexthops)
> assmued that "locally destined, and routed packets, never trigger
> PMTU events or redirects that will be processed by us".
> 
> However, it seems that tunnel devices do trigger PMTU events in certain
> cases. At least ip_gre, ip6_gre, sit, and ipip do use the inner flow's
> skb_dst(skb)->ops->update_pmtu to propage mtu information from the
> outer flows. These can cause the inner flow mtu to be decreased. If
> next hop exceptions are not consulted for pmtu, IP fragmentation will
> not be done properly for these routes.
> 
> It also seems that we really need to have the PMTU information always
> for netfilter TCPMSS clamp-to-pmtu feature to work properly.
> 
> So for the time being, cache separate copies of input routes for
> each next hop exception.
> 
> Signed-off-by: Timo Teräs <timo.teras@iki.fi>

	Looks good to me

Reviewed-by: Julian Anastasov <ja@ssi.bg>

> ---
> Seems that the previous send was marked as RFC, and got no review
> comments. No alternate patches seem to have been committed either.
> 
> I'm resending now without RFC tag, and rebased against current
> net-next. I've been using this locally for several weeks and have
> not found any problems, and this does fix the two regression bugs
> mentioned above.

Regards

--
Julian Anastasov <ja@ssi.bg>
--280144257-1976251345-1372323135=:2436--
