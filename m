From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 04/31 DO NOT APPLY] enable netfilter in netns
Date: Mon, 21 Jul 2008 21:14:16 +0400
Message-ID: <20080721171416.GA13507@martell.zuzino.mipt.ru>
References: <20080721163358.GH13264@martell.zuzino.mipt.ru> <4884C0EC.80204@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, den@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:13446 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbYGURQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 13:16:05 -0400
Received: by ug-out-1314.google.com with SMTP id h2so280995ugf.16
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 10:16:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4884C0EC.80204@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 07:01:32PM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> 	Only for testing.
>
> Thanks for posting this, I'll try to get this reviewed and
> merged before the merge window closes.
>
> Just one question since this patch is marked DO NO APPLY -
> are the remaining patches meant for applying?

Yes!

Let's ask Den about this particular patch, though. :-)

> Is there any further work left until netfilter is fully namespace aware?

We discussed this in "unlock iptables in netns" thread
http://marc.info/?l=linux-netdev&m=121311890005554&w=2

With this patchset conntracking and NAT are largely netns-ready (I hope),
the list shrinks.

	ebtable_filter
	ebtable_nat
	selinux
	decnet
	IPv6 REJECT
	+ several individual matches/etc 

As for other stuff,
	conntrack statistics (trivial)
	ctnetlink (stubbed to init_net, dunno what it is)
	NF_LOG, NF_QUEUE (deprecated? don't bother at all?)



grep init_net -w -n -r net/netfilter/ net/ipv4/netfilter/ net/ipv6/netfilter/
shows more or less what works, and what doesn't.

