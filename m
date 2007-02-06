From: David Miller <davem@davemloft.net>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Tue, 06 Feb 2007 13:23:57 -0800 (PST)
Message-ID: <20070206.132357.58458400.davem@davemloft.net>
References: <20070206123401.GA8052@elte.hu>
	<20070206.114325.98862918.davem@davemloft.net>
	<20070206210250.GB25430@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, kaber@trash.net,
	dipankar@in.ibm.com, paulmck@us.ibm.com
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52698
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965528AbXBFVYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 16:24:22 -0500
In-Reply-To: <20070206210250.GB25430@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 6 Feb 2007 22:02:51 +0100

> So i'm wondering what other assumptions there are (or can be) 
> about rcu_read_lock() also being a preempt-off point. Thanks!

I showed the examples in my detailed analysis yesterday.

Beause I love hearing myself say the same thing over and over so much
I'll restate it for you.

net/netfilter/nf_conntrack_core.c, calls:

	l4proto = __nf_ct_l4proto_find((u_int16_t)pf, protonum);

whichs assumes that preemption is disabled.
