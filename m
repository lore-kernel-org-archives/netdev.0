From: Patrick McHardy <kaber@trash.net>
Subject: Re: ip6t_SYNPROXY crashes kernel
Date: Sat, 1 Aug 2015 14:54:45 +0200
Message-ID: <20150801125444.GB18502@acer.localdomain>
References: <20150727222716.GG20951@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: pablo@netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46081 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbbHAMyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Aug 2015 08:54:53 -0400
Content-Disposition: inline
In-Reply-To: <20150727222716.GG20951@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.07, Phil Sutter wrote:
> Hi,
> 
> When synproxy_send_server_ack() calls synproxy_send_tcp(), it passes
> NULL as third parameter (struct nf_conntrack *nfct). And the first thing
> synproxy_send_tcp() does, is dereference it:
> 
> | struct net *net = nf_ct_net((struct nf_conn *)nfct);
> 
> I could not find a commit leading to this breakage in the commit log,
> which makes me doubt ip6t_SYNPROXY has ever worked at all.
> 
> If you need one, I have a reproducer at hand. (Though I would want to
> strip it down a bit first.) Just let me know.

Thanks, looks like I never tested this with netns enabled. Would you
care to provide a patch? An easy fix seems to be to pass the synproxy_net
struct to synproxy_send_tcp() and use nf_ct_net(snet->tmpl) instead.
