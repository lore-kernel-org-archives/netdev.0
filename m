From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3] netfilter: nf_conntrack: use safer way to lock all
 buckets
Date: Tue, 19 Jan 2016 20:09:38 +0100
Message-ID: <20160119190938.GA25130@salvia>
References: <1453163031-31443-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41578 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757413AbcASTJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2016 14:09:51 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id D56FF2791AE
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 20:09:50 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C45BBDA865
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 20:09:50 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B9B27DA86F
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 20:09:44 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1453163031-31443-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2016 at 07:23:51PM -0500, Sasha Levin wrote:
> When we need to lock all buckets in the connection hashtable we'd attempt to
> lock 1024 spinlocks, which is way more preemption levels than supported by
> the kernel. Furthermore, this behavior was hidden by checking if lockdep is
> enabled, and if it was - use only 8 buckets(!).
> 
> Fix this by using a global lock and synchronize all buckets on it when we
> need to lock them all. This is pretty heavyweight, but is only done when we
> need to resize the hashtable, and that doesn't happen often enough (or at all).
> 
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.

I'm including the Reviewed-by tag from Florian in this patch.
