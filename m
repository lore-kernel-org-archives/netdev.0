From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: lock_sock_nested in sctp_sock_migrate
Date: Mon, 25 Jun 2007 16:38:20 -0400
Message-ID: <468027BC.1070706@hp.com>
References: <20070622221446.GB7547@mami.zabbo.net> <46802477.5030005@hp.com> <46802460.3080303@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Zach Brown <zach.brown@oracle.com>,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:45288 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbXFYUi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 16:38:27 -0400
In-Reply-To: <46802460.3080303@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Vlad Yasevich wrote:
>> Hm... This is another case of of two different sockets taking the same
>> lock...
>>
>> Arjan,  did this every get fixed, or is the nested locking the right
>> solution
>> to this?
>>
> 
> for this specific case it's ok and the nested solution is right.
> In the general case it's obviously not safe to take the locks of two
> sockets in "unspecified" order....
> 

Well, in this case the order is very carefully specified, but I was more
interested in what the right solution is.

The newsk, from the patch, has just been created, but needs to be locked
to prevent soft_irq from queuing packets to it while we are mucking around.
This is the same case as the accept case that had issues some time ago.

-vlad
