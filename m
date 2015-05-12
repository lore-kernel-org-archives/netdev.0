From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] netconsole: implement extended console support
Date: Tue, 12 May 2015 19:23:22 -0400 (EDT)
Message-ID: <20150512.192322.2233784105592482987.davem@davemloft.net>
References: <1431362494-9874-5-git-send-email-tj@kernel.org>
	<20150511.132339.403868463230045095.davem@davemloft.net>
	<20150511203745.GI11388@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penguin-kernel@I-love.SAKURA.ne.jp,
	sd@queasysnail.net
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150511203745.GI11388@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Mon, 11 May 2015 16:37:45 -0400

> The current code does produce the latter outcome.
> 
> 	header = msg;
> 	body = memchr(msg, ';', msg_len);
> 	if (WARN_ON_ONCE(!body))
> 		return;
> 
> 	header_len = body - header;
> 	body_len = msg_len - header_len - 1;
> 	body++;
> 
> @body points to ';' after memchr(), so @header_len doesn't include
> ';'.  @body is incremented after calculating @header_len.

Ok, thanks for explaining, it is clear to me now.

Second question, is there an upper bound on this header size?

Because if there is, it seems to me that there is no reason why we
can't just avoid the fragmentation support altogether.

The current code limits to 1000 bytes, and that limit seems arbitrary.
Obviously this code is meant to work on interfaces with an ethernet
MTU or larger.  So you could bump the limit enough to accomodate the
new header size, yet still be within the real constraints.

What do you think?
