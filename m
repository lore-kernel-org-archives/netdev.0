From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sctp: hang in sctp_remaddr_seq_show
Date: Mon, 18 Mar 2013 13:48:48 -0700
Message-ID: <1363639728.21184.8.camel@edumazet-glaptop>
References: <51434D78.9030308@oracle.com>
	 <20130318110415.GA9478@hmsreliant.think-freely.org>
	 <1363620340.29475.132.camel@edumazet-glaptop> <5147333A.3010907@gmail.com>
	 <20130318203202.GB9478@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>, sri@us.ibm.com,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:57683 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755119Ab3CRUsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 16:48:51 -0400
In-Reply-To: <20130318203202.GB9478@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 16:32 -0400, Neil Horman wrote:

> Vlads, right.  We need to grab the rcu lock before the read lock, but we should
> probably use the rcu_read_lock_bh variant, since we're going to disable bottom
> halves anyway.
> Neil

rcu_read_lock_bh() and {local_bh_disable();rcu_read_lock();} have quite
different semantics.

If you use rcu_read_lock_bh(), you also need to change rcu_dereference()
calls to rcu_dereference_bh() variant.
