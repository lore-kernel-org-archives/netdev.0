From: "Zhu, Yi" <yi.zhu@intel.com>
Subject: RE: [PATCH V2 5/7] sctp: use limited socket backlog
Date: Wed, 3 Mar 2010 22:19:46 +0800
Message-ID: <DA586906BA1FFC4384FCFD6429ECE860A45A699B@shzsmsx502.ccr.corp.intel.com>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-3-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-4-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-5-git-send-email-yi.zhu@intel.com> <4B8E6DD0.1020603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29554 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754188Ab0CCOTu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 09:19:50 -0500
In-Reply-To: <4B8E6DD0.1020603@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich@hp.com> wrote:

> I think this will result in a double-free of the skb, because sctp_chunk_free
> attempts to free the skb that's been assigned to the chunk.  You can set the skb
> to NULL to get around that.

Ah, I missed that. Thanks!

<...>

> You also leak the ref counts here since now it's possible to not add a packet to
> the backlog queue.  That means you'll take refs, but never drop them because
> the receive routing will never run.

Good catch. I'll fix it.

BTW, does the current backlog limit (sysctl_rmem_default[1] << 1) enough for sctp?
I noticed the sysctl_sctp_rmem[1] is set to 373500 in my box.

Thanks,
-yi

