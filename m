From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [PATCH 07/23] netfilter: x_tables: check standard target size too
Date: Sun, 05 Jun 2016 23:11:36 +0200
Message-ID: <8760tn5ojb.fsf@linux-m68k.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
	<1461332394-3994-8-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:47481 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbcFEVLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 17:11:41 -0400
In-Reply-To: <1461332394-3994-8-git-send-email-pablo@netfilter.org> (Pablo
	Neira Ayuso's message of "Fri, 22 Apr 2016 15:39:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> From: Florian Westphal <fw@strlen.de>
>
> We have targets and standard targets -- the latter carries a verdict.
>
> The ip/ip6tables validation functions will access t->verdict for the
> standard targets to fetch the jump offset or verdict for chainloop
> detection, but this happens before the targets get checked/validated.
>
> Thus we also need to check for verdict presence here, else t->verdict
> can point right after a blob.
>
> Spotted with UBSAN while testing malformed blobs.

This breaks iptables on PPC32.

# iptables -nL
iptables v1.4.21: can't initialize iptables table `filter': Table does not exist (do you need to insmod?)
Perhaps iptables or your kernel needs to be upgraded.
# modprobe iptable-filter
FATAL: Error inserting iptable_filter (/lib/modules/4.7.0-rc1/kernel/net/ipv4/netfilter/iptable_filter.ko): Invalid argument

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
