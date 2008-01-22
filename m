From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] netns netfilter: return new table from {arp,ip,ip6}t_register_table()
Date: Tue, 22 Jan 2008 17:57:16 +0100
Message-ID: <4796206C.4060100@trash.net>
References: <20080121145357.GH27615@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53748 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbYAVQ5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 11:57:46 -0500
In-Reply-To: <20080121145357.GH27615@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Typical table module registers xt_table structure (i.e. packet_filter)
> and link it to list during it. We can't use one template for it because
> corresponding list_head will become corrupted. We also can't unregister
> with template because it wasn't changed at all and thus doesn't know in
> which list it is.
> 
> So, we duplicate template at the very first step of table registration.
> Table modules will save it for use during unregistration time and actual
> filtering.
> 
> Do it at once to not screw bisection.

Applied, thanks.

> P.S.: renaming i.e. packet_filter => __packet_filter is temporary until
>       full netnsization of table modules is done.

It seems this could have been avoided by ordering the patches
differently (I probably would also have done 4/5 as 1/5).
