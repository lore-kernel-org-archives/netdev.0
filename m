From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [3.19.0-rc4+] rhashtable: BUG kmalloc-2048 (Not tainted): Poison
 overwritten
Date: Mon, 19 Jan 2015 12:59:28 +0000
Message-ID: <20150119125928.GB7672@casper.infradead.org>
References: <54BCBA35.2080103@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "richard.alpe@ericsson.com >> Richard Alpe"
	<richard.alpe@ericsson.com>, Netdev <netdev@vger.kernel.org>,
	tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55504 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbbASM7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 07:59:31 -0500
Content-Disposition: inline
In-Reply-To: <54BCBA35.2080103@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/15 at 04:03pm, Ying Xue wrote:
> On 3.19.0-rc4+, I encountered below error with attached test
> case(bind_netlink.c). Please execute the following commands to reproduce
> the error:
> 
> gcc -Wall -o bind_netlink bind_netlink.c
> ./bind_netlink 1000
> 
> By the way, if we run another test case(bind_tipc.c), the similar issue
> will happen on TIPC socket.
> 
> Therefore, it seems that the issue is closely associated with rhashtable
> instead of specific stacks like netlink or tipc.

Looks like a RCU read side critical section was missed. Does the TIPC
poision warning look the same? offset 2048?
