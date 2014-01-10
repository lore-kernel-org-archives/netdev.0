From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] xen-netback: stop vif thread spinning if
 frontend is unresponsive
Date: Thu, 09 Jan 2014 23:06:29 -0500 (EST)
Message-ID: <20140109.230629.123446421132170371.davem@davemloft.net>
References: <1389184918-42790-1-git-send-email-paul.durrant@citrix.com>
	<20140108193716.GA16009@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.durrant@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, ian.campbell@citrix.com,
	david.vrabel@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaAJEGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 23:06:31 -0500
In-Reply-To: <20140108193716.GA16009@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Wed, 8 Jan 2014 19:37:16 +0000

> On Wed, Jan 08, 2014 at 12:41:58PM +0000, Paul Durrant wrote:
>> The recent patch to improve guest receive side flow control (ca2f09f2) had a
>> slight flaw in the wait condition for the vif thread in that any remaining
>> skbs in the guest receive side netback internal queue would prevent the
>> thread from sleeping. An unresponsive frontend can lead to a permanently
>> non-empty internal queue and thus the thread will spin. In this case the
>> thread should really sleep until the frontend becomes responsive again.
>> 
>> This patch adds an extra flag to the vif which is set if the shared ring
>> is full and cleared when skbs are drained into the shared ring. Thus,
>> if the thread runs, finds the shared ring full and can make no progress the
>> flag remains set. If the flag remains set then the thread will sleep,
>> regardless of a non-empty queue, until the next event from the frontend.
>> 
>> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
>> Cc: Wei Liu <wei.liu2@citrix.com>
>> Cc: Ian Campbell <ian.campbell@citrix.com>
>> Cc: David Vrabel <david.vrabel@citrix.com>
> 
> Acked-by: Wei Liu <wei.liu2@citrix.com>

Applied.
