From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Thu, 16 Oct 2008 22:06:24 -0700
Message-ID: <20081016220624.512a1e61@extreme>
References: <20081006225210.GA29794@hmsreliant.think-freely.org>
	<48EAEFF9.1000606@cosmosbay.com>
	<20081013182655.GA9505@hmsreliant.think-freely.org>
	<20081015.235556.61915120.davem@davemloft.net>
	<20081016114155.GA15877@hmsreliant.think-freely.org>
	<48F732CB.8030704@cosmosbay.com>
	<20081016163644.GA2933@localhost.localdomain>
	<20081016233517.GA21243@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34795 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbYJQFG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2008 01:06:27 -0400
In-Reply-To: <20081016233517.GA21243@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

O
> +static inline int rt_caching(struct net *net)
> +{
> +	return net->ipv4.current_rt_cache_rebuild_count <=
> +		net->ipv4.sysctl_rt_cache_rebuild_count;
> +}

Why not?

static inline  bool rt_caching(const struct net *)

 

> +static inline int compare_hash_inputs(struct flowi *fl1, struct flowi *fl2)
> +{
> +	return (__force u32)(((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
> +		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr) |
> +		(fl1->iif ^ fl2->iif)) == 0);
> +}

static inline bool compare_hash_inputs(const struct flowi *fl1, struct flowi *fl2)

...
