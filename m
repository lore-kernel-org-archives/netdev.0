From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 32/34] netfilter: bridge: move br_netfilter out of the
 core
Date: Tue, 30 Sep 2014 08:58:02 -0700
Message-ID: <20140930085802.15460008@urahara>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
	<1411994363-8451-33-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:63606 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbaI3P6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 11:58:16 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so2055578pdj.18
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 08:58:15 -0700 (PDT)
In-Reply-To: <1411994363-8451-33-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Sep 2014 14:39:21 +0200
Pablo Neira Ayuso <pablo@netfilter.org> wrote:

> Jesper reported that br_netfilter always registers the hooks since
> this is part of the bridge core. This harms performance for people that
> don't need this.
> 
> This patch modularizes br_netfilter so it can be rmmod'ed, thus,
> the hooks can be unregistered. I think the bridge netfilter should have
> been a separated module since the beginning, Patrick agreed on that.
> 
> Note that this is breaking compatibility for users that expect that
> bridge netfilter is going to be available after explicitly 'modprobe
> bridge' or via automatic load through brctl.
> 
> However, the damage can be easily undone by modprobing br_netfilter.
> The bridge core also spots a message to provide a clue to people that
> didn't notice that this has been deprecated.
> 
> On top of that, the plan is that nftables will not rely on this software
> layer, but integrate the connection tracking into the bridge layer to
> enable stateful filtering and NAT, which is was bridge netfilter users
> seem to require.
> 
> This patch still keeps the fake_dst_ops in the bridge core, since this
> is required by when the bridge port is initialized. So we can safely
> modprobe/rmmod br_netfilter anytime.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Acked-by: Florian Westphal <fw@strlen.de>

I think this is a good idea but you can't break users.

We need to figure out a way to autoload br_netfilter module on first use.
