From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] bridge: only provide proxy ARP when CONFIG_INET is enabled
Date: Tue, 13 Jan 2015 22:33:48 +0100
Message-ID: <4681500.x6CYopasp1@wuerfel>
References: <56868207.rHBDZL3pbk@wuerfel> <20150113.155740.1237959632603319909.davem@davemloft.net> <54B58AAC.7090001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	netdev@vger.kernel.org, kyeyoonp@codeaurora.org,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:54229 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbbAMVd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:33:58 -0500
In-Reply-To: <54B58AAC.7090001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 January 2015 14:14:20 David Ahern wrote:
> 
> Rather than connect CONFIG_BRIDGE to CONFIG_INET, why not make 
> br_do_proxy_arp (and setting BR_PROXYARP flag) a no-op if CONFIG_INET is 
> not set?
> 
> #ifdef CONFIG_INET
> #else
> static inline void br_do_proxy_arp(...args...)
> {
> }
> #endif
> 
> That covers both arp_tbl and arp_send.

The effect is very similar to my patch (probably same object code), the
only difference should be that it would add an ugly #ifdef instead of
the preferred IS_ENABLED() check, so you don't get any compile-time
coverage of the function. It's not really important because everybody
has CONFIG_INET enabled in practice and it does get more than enough
compile-time coverage.

	Arnd
