From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Moving frags and SKBTX_DEV_ZEROCOPY skbs
Date: Wed, 14 May 2014 14:40:54 +0100
Message-ID: <53737266.5040601@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	<kvm@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:28842 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbaENNk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 09:40:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Recently I've investigated issues around SKBTX_DEV_ZEROCOPY skbs where 
the frags list were modified. I came across this function skb_shift(), 
which moves frags between skbs. And there are a lot more of such kind, 
skb_split or skb_try_coalesce, for example.
It could be a dangerous thing if a frag is referenced from an skb which 
doesn't have the original destructor_arg, and to avoid that 
skb_orphan_frags should be called. Although probably these functions are 
not normally touched in usual usecases, I think it would be useful to 
review core skb functions proactively and add an skb_orphan_frags 
everywhere where the frags could be referenced from other places.
Any opinion about this?

Regards,

Zoltan
