From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Fri, 21 Nov 2014 13:55:00 -0500 (EST)
Message-ID: <20141121.135500.1677711058185319746.davem@davemloft.net>
References: <CAHA+R7P9XhGQZXFy6frxOyZJ4rX_MdVgY3kAPE1_wDNcvYd_yA@mail.gmail.com>
	<23563.1416523985@famine>
	<CAHA+R7Pnn4TxRQcR4KBRrZV8mqsm-YznMMvXVasji07caY9b1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jay.vosburgh@canonical.com, eric.dumazet@gmail.com,
	wen.gang.wang@oracle.com, netdev@vger.kernel.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaKUSzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 13:55:02 -0500
In-Reply-To: <CAHA+R7Pnn4TxRQcR4KBRrZV8mqsm-YznMMvXVasji07caY9b1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Fri, 21 Nov 2014 10:17:12 -0800

> On Thu, Nov 20, 2014 at 2:53 PM, Jay Vosburgh
> <jay.vosburgh@canonical.com> wrote:
>> Cong Wang <cwang@twopensource.com> wrote:
>>
>>>Also, no one seems to care about my previous question:
>>>why only bonding has the problem?
>>
>>         Bonding has the problem because it stashes a pointer to a data
>> structure (the header_ops) from another module, and when that module is
>> unloaded the dangling pointer may be dereferenced if it's not either
>> cleared or made to never go away.
> 
> I knew, please re-read my question, I was asking why ONLY bonding
> has the problem, i.e. why not neigh or whatever else calling
> header_ops->foo()? :)

They are either static only (ipv4) or cannot be unloaded as a module
after being loaded (ipv6).
