From: Patrick McHardy <kaber@trash.net>
Subject: Re: conntrack timers usage
Date: Mon, 13 Oct 2008 15:20:39 +0200
Message-ID: <48F34B27.50001@trash.net>
References: <200810130149.25635.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36647 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757524AbYJMNUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 09:20:41 -0400
In-Reply-To: <200810130149.25635.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> The story with excessive timers usage continue.
> 
> Here is my results from /proc/timer_stats for 30 seconds (150Mbps traffic)
> ...
> And here is netfilter usage, looks like ....
> I did also sysctl -w net.netfilter.nf_conntrack_acct=0
> 
>    1,     0 swapper          __nf_ct_refresh_acct (death_by_timeout)
>     1,     0 swapper          __nf_ct_refresh_acct (death_by_timeout)
>     1,     0 swapper          __nf_ct_refresh_acct (death_by_timeout)
>     1,     0 swapper          __nf_ct_refresh_acct (death_by_timeout)
>     1,     0 swapper          __nf_ct_refresh_acct (death_by_timeout)
>     1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
>     1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
>     1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
>     1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
>     1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
>     1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
>     1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
>     1,     0 swapper          __nf_conntrack_confirm (death_by_timeout)
> ....
> 
> Router-Dora ~ # cat /proc/timer_stats |grep '__nf'|wc -l
> 1005
> 
> Is it important to do so much calls to timers in conntrack?
> Precision on it is not more than 1 second.

There's one timer per conntrack. As you noticed, we only update
timers for delta >= 1s, but with many conntracks, that still adds
up to a lot.
