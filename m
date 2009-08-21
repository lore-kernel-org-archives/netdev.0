From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] qlge: Move TX completion processing to
 send path.
Date: Fri, 21 Aug 2009 13:25:28 -0700 (PDT)
Message-ID: <20090821.132528.248292748.davem@davemloft.net>
References: <1250725991-7155-2-git-send-email-ron.mercer@qlogic.com>
	<20090820.021854.254431313.davem@davemloft.net>
	<20090821172301.GB12770@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shashank.pandhare@qlogic.com,
	jagannatha.narayanaswami@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932482AbZHUUZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 16:25:16 -0400
In-Reply-To: <20090821172301.GB12770@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Fri, 21 Aug 2009 10:23:01 -0700

> I'll move TX completions into NAPI as you indicated.  I still need to
> dedicate the MSIX vectors to RSS, but I will give each vector a number
> of TX rings to service in NAPI as well.

That might actually be, in fact, optimal.  Because if you process
the TX completions first this primes the SKB allocator up with
fresh SKBs to replenish the RX ring particularly in forwarding
workloads.
