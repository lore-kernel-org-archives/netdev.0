From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv6/addrconf: speedup /proc/net/if_inet6 filling
Date: Wed, 4 Jan 2012 08:22:00 -0800
Message-ID: <20120104082200.437df26a@nehalam.linuxnetplumber.net>
References: <1325669495-5626-1-git-send-email-mmaruseac@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Mihai Maruseac <mmaruseac@ixiacom.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: Mihai Maruseac <mihai.maruseac@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52192 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756144Ab2ADQWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 11:22:04 -0500
In-Reply-To: <1325669495-5626-1-git-send-email-mmaruseac@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  4 Jan 2012 11:31:35 +0200
Mihai Maruseac <mihai.maruseac@gmail.com> wrote:

> This ensures a linear behaviour when filling /proc/net/if_inet6 thus making
> ifconfig run really fast on IPv6 only addresses. In fact, with this patch and
> the IPv4 one sent a while ago, ifconfig will run in linear time regardless of
> address type.
> 
> IPv4 related patch: f04565ddf52e401880f8ba51de0dff8ba51c99fd
> 	 dev: use name hash for dev_seq_ops
> 	 ...
> 
> Some statistics (running ifconfig > /dev/null on a different setup):
> 
> iface count / IPv6 no-patch time / IPv6 patched time / IPv4 time
> ----------------------------------------------------------------
>       6250  |       0.23 s       |      0.13 s       |  0.11 s
>      12500  |       0.62 s       |      0.28 s       |  0.22 s
>      25000  |       2.91 s       |      0.57 s       |  0.46 s
>      50000  |      11.37 s       |      1.21 s       |  0.94 s
>     128000  |      86.78 s       |      3.05 s       |  2.54 s
> 
> Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
> Cc: Daniel Baluta <dbaluta@ixiacom.com>
> ---
>  net/ipv6/addrconf.c |   43 ++++++++++++++++++++++++++++---------------
>  1 files changed, 28 insertions(+), 15 deletions(-)
> 


What about netlink? Also ifconfig is really considered deprecated,
especially for ipv6 usage.
