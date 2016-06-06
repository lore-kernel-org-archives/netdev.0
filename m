From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter/nflog: nflog-range does not truncate packets
Date: Tue, 7 Jun 2016 00:31:06 +0200
Message-ID: <20160606223106.GA1621@salvia>
References: <20160602002354.GG1644@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50233 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbcFFWbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2016 18:31:25 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 17511CD6F13
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 00:31:22 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0943F9EBB0
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 00:31:22 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 018F79EBAE
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 00:31:20 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20160602002354.GG1644@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2016 at 08:23:54PM -0400, Vishwanath Pai wrote:
> netfilter/nflog: nflog-range does not truncate packets
> 
> The --nflog-range parameter from userspace is ignored in the kernel and
> the entire packet is sent to the userspace. The per-instance parameter
> copy_range still works, with this change --nflog-range will have
> preference over copy_range.

I think it's reasonable to assume that --nflog-range from the rule
applies globally to any instance.

However, per-instance copy_range has prevailed over --nflog-range
since the beginning, so I would follow a more conservative approach,
ie. remain copy_range in preference over --nflog-range.

So I'd suggest you invert this logic.

Let me know, thanks.
