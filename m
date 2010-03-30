From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 10/12] l2tp: Add L2TP ethernet pseudowire support
Date: Tue, 30 Mar 2010 09:32:52 -0700
Message-ID: <20100330093252.60d9cbee@nehalam>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>
	<20100330161819.9628.10853.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33053 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754433Ab0C3R0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 13:26:49 -0400
In-Reply-To: <20100330161819.9628.10853.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 17:18:19 +0100
James Chapman <jchapman@katalix.com> wrote:

> +struct l2tp_eth_net {
> +	struct list_head l2tp_eth_dev_list;
> +	rwlock_t l2tp_eth_lock;
> +};

Reader/write locks are discouraged because they are slower than
spin locks.  If you have lots of readers use RCU, if reading
is infrequent just use a spin lock.

-- 
