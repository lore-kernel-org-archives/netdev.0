From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Add counters tx_bytes and rx_bytes for ethtool
Date: Tue, 25 May 2010 16:15:39 -0700 (PDT)
Message-ID: <20100525.161539.104072714.davem@davemloft.net>
References: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: junchangwang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60382
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932370Ab0EYXP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 19:15:29 -0400
In-Reply-To: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Junchang Wang <junchangwang@gmail.com>
Date: Tue, 25 May 2010 22:19:46 +0800

> Traffic stats counters (rx_bytes and tx_bytes) in net_device are
> "unsigned long". On 32-bit systems, they wrap around every few
> minutes, giving out wrong answers to the amount of traffic. To get the
> right message, another available approach is "ethtool -S". However,
> r8169 didn't support those two counters so far.
> 
> Add traffic counters tx_bytes and rx_bytes with 64-bit width for
> ethtool. On 32-bit systems, gcc treats each one as two 32-bit
> variables, making the increment not "atomic". But there is no sync
> issue since the updates to the counters are serialized by driver logic
> in any case. Results provided by ethtool maybe slightly biased if the
> read and update operations are interleaved. But the results are much
> better than the original ones that always fall into the range from 0
> to 4GiB.
> 
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>

I absolutely do not want to see drivers start doing this, so right
off the bat I am not going to apply this patch.

If the problem is that people want 64-bit counters available for core
statistics on 32-bit systems, we do not fix that problem by hacking
every single driver to provide them side-band via ethtool.

First of all, we now have "struct rtnl_link_stats64" in
linux/if_link.h, it's there to start combating this problem
generically, for every device, rather than the way you are trying
handle it only for one specific driver at a time.

So that's the area where you should start looking to solve these kinds
of problem.
