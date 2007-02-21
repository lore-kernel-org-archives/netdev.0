From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Extensible hashing and RCU
Date: 21 Feb 2007 13:41:26 +0100
Message-ID: <p73y7mrd6o9.fsf@bingen.suse.de>
References: <20070204074143.26312.qmail@science.horizon.com>
	<200702201104.16200.dada1@cosmosbay.com>
	<20070220104418.GA5262@2ka.mipt.ru>
	<200702201209.52388.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org,
	bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:42561 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932422AbXBULlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 06:41:50 -0500
In-Reply-To: <200702201209.52388.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> writes:
> 
> For example, sock_wfree() uses 1.6612 % of cpu because of false sharing of 
> sk_flags (dirtied each time SOCK_QUEUE_SHRUNK is set :(

Might be easily fixable by moving the fields around a bit?

> If we want to optimize tcp, we should reorder fields to reduce number of cache 
> lines, not change algos. struct sock fields are currently placed to reduce 
> holes, while they should be grouped by related fields sharing cache lines.

Regrouping is definitely a good thing; but I'm not sure why you are so
deadset against exploring other data structures. The promise of RCUing
and avoiding the big hash tables seems alluding to me, even if it 
only breaks even in the end in terms of cycles.

-Andi
