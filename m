From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix UDP filter condition when do checksum
Date: Mon, 31 Jul 2006 05:02:01 -0700 (PDT)
Message-ID: <20060731.050201.18308966.davem@davemloft.net>
References: <1154342022.3959.10.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47319
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750895AbWGaMCO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 08:02:14 -0400
To: yjwei@nanjing-fnst.com
In-Reply-To: <1154342022.3959.10.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yjwei@nanjing-fnst.com>
Date: Mon, 31 Jul 2006 06:33:42 -0400

> In udp_queue_rcv_skb(), checksum condition is error. When UDP filter is
> set, checksum is be done, but if UDP filter is not set, checksum will
> not be done. So I think this is a BUG.

It is not a bug, we defer the checksum, when we can, to sys_recvmsg()
where we can combine the copy into userspace and the checksum
calculation into one operation.

We cannot do this deferral when there is a filter attached, and that
is why the check is the way it is.
