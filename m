From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/6 net-next] rhashtable fixes
Date: Fri, 30 Jan 2015 09:29:11 +0000
Message-ID: <20150130092911.GA2313@casper.infradead.org>
References: <cover.1422576760.git.tgraf@suug.ch>
 <54CB4A95.9060000@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33177 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbbA3J3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 04:29:14 -0500
Content-Disposition: inline
In-Reply-To: <54CB4A95.9060000@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/15 at 05:10pm, Ying Xue wrote:
> Hi Thomas,
> 
> I make sure that my local net-next tree is synchronized to the latest
> version in which the commit fe6a043c535acfec8f8e554536c87923dcb45097
> ("rhashtable: rhashtable_remove() must unlink in both tbl and
> future_tbl") is already contained, and then I manually applied the whole
> series patches. But when I repeatedly run the test case I originally
> posted, soft lockup happens. Please see its relevant log:

Right, I see the same soft lockup. Interestingly I cannot trigger it
with the rht test code. I can only trigger it with your Netlink socket
creation stress test. It is definitely related to the deferred worker,
when I disable growing, then the bug disappears. I think that the
expansion leaves a race open in which remove cannot find certain entries
(I verified this by adding a BUG_ON() when rhashtable_remove() could not
find a match). This then keeps an entry on the list which has already
been freed.

However, I think this was present before these fixes but hidden as the
lockup requires a lot more iterations of your stress test on my
machine.
