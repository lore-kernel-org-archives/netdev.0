From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 v2][NET] gen_estimator: faster gen_kill_estimator
Date: Mon, 21 Jan 2008 16:29:18 -0800 (PST)
Message-ID: <20080121.162918.148129860.davem@davemloft.net>
References: <20080120234659.GA2691@ami.dom.local>
	<20080121223137.GB2758@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slavon@bigtelecom.ru, kaber@trash.net,
	hadi@cyberus.ca
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56214
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755822AbYAVA3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 19:29:12 -0500
In-Reply-To: <20080121223137.GB2758@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 21 Jan 2008 23:31:37 +0100

> 
> So, let's try something easy first: #ifdef __KERNEL__. (I know there
> are many esthetes around, but since this subject looks quite dirty...)

You can't do this, the attribute is copied to the user netlink SKB
using sizeof(struct gnet_stats_rate_est) as the size (or more
specifically sizeof(*p) where p is a pointer to this structure).

Therefore this new patch has the same exact problem.

Fix this right, make a structure like:

struct kernel_gnet_stats_rate_est {
	struct gnet_stats_rate_est	est;
	void				*gen_estimator;
}

And update all the code as needed.
