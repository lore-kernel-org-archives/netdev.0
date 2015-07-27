From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] fib_trie: Drop unnecessary calls to
 leaf_pull_suffix
Date: Mon, 27 Jul 2015 14:51:44 -0700 (PDT)
Message-ID: <20150727.145144.1108615217553792979.davem@davemloft.net>
References: <55B6612C.7050506@cumulusnetworks.com>
	<20150727195631.26840.93266.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbbG0Vvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:51:45 -0400
In-Reply-To: <20150727195631.26840.93266.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 27 Jul 2015 13:08:06 -0700

> It was reported that update_suffix was taking a long time on systems where
> a large number of leaves were attached to a single node.  As it turns out
> fib_table_flush was calling update_suffix for each leaf that didn't have all
> of the aliases stripped from it.  As a result, on this large node removing
> one leaf would result in us calling update_suffix for every other leaf on
> the node.
> 
> The fix is to just remove the calls to leaf_pull_suffix since they are
> redundant as we already have a call in resize that will go through and
> update the suffix length for the node before we exit out of
> fib_table_flush or fib_table_flush_external.
> 
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied and queued up for -stable, thanks.
