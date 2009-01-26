From: David Miller <davem@davemloft.net>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Sun, 25 Jan 2009 21:34:36 -0800 (PST)
Message-ID: <20090125.213436.268287293.davem@davemloft.net>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com>
	<4978F804.3060502@cs.wisc.edu>
	<49794612.9010204@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	olaf.kirch@oracle.com, tgraf@suug.ch, kkeil@suse.de,
	herbert@gondor.apana.org.au
To: michaelc@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750753AbZAZFed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 00:34:33 -0500
In-Reply-To: <49794612.9010204@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Christie <michaelc@cs.wisc.edu>
Date: Thu, 22 Jan 2009 22:22:42 -0600

> Attached is a patch made against the scsi maintainer's tree (I think
> it should also apply to linus's) that converts iscsi to use
> skb_copy_bits. It is lightly tested. If there is no benefit in
> having skb_find_text use skb_seq_read maybe we can just kill it, so
> people do not have to maintain two helpers that provide similar
> functionality.

Regardless of what we decide to do with iSCSI we have to make this
function work properly as long as there is a user in the tree.

This iterator can in fact be more efficient than using copy
bits since copy bits doesn't remember any state from previous
invocations whereas the iterator does.  So if you call it
multiple times on the same SKB that's a lot of wasted work.

In fact I'm pretty sure that's why we added it for textsearch,
because in that application we're constantly beating through
the same SKB via the testsearch state machine.

Therefore, keeping it's use for iSCSI would be beneficial.
