From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-2.6 PATCH 2/6] net: remove kfree_skb on a NULL pointer in
 af_netlink.c
Date: Mon, 21 Sep 2009 12:04:35 +0000
Message-ID: <4AB76BD3.80802@intel.com>
References: <20090918005708.25594.52575.stgit@localhost.localdomain>	<20090918005729.25594.14261.stgit@localhost.localdomain> <20090917.182445.240085155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62605 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505AbZIUTe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 15:34:27 -0400
In-Reply-To: <20090917.182445.240085155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 17 Sep 2009 17:57:29 -0700
>
>   
>> From: John Fastabend <john.r.fastabend@intel.com>
>>
>> This removes a kfree_skb that is being called on a NULL pointer when
>> do_one_broadcast() is sucessful.  And moves the kfree_skb into
>> do_one_broadcast() for the error case.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>     
>
> kfree_skb() on a NULL pointer is completely legal.
>   
OK, but this depends on the unlikely() macro in kfree_skb() to catch a 
case that is the expected non-error case. Would it be better to wrap the 
kfree_skb() in an if statement to avoid hitting the unlikely() macro?  
Or is the performance hit from the unlikely() macro so small this is not 
an issue?  Thanks for looking at these.

john.

