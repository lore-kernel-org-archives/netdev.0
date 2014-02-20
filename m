From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix bond_arp_rcv() race of
 curr_active_slave
Date: Thu, 20 Feb 2014 13:21:16 -0500 (EST)
Message-ID: <20140220.132116.2211832039801912191.davem@davemloft.net>
References: <1392894477-5477-1-git-send-email-vfalico@redhat.com>
	<20140220111519.GD1181@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com, fubar@us.ibm.com,
	andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753098AbaBTSVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 13:21:17 -0500
In-Reply-To: <20140220111519.GD1181@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 20 Feb 2014 12:15:19 +0100

> On Thu, Feb 20, 2014 at 12:07:57PM +0100, Veaceslav Falico wrote:
>>bond->curr_active_slave can be changed between its deferences, even to
>>NULL, and thus we might panic.
>>
>>We're always holding the rcu
>>(rx_handler->bond_handle_frame()->bond_arp_rcv())
>>so fix this by rcu_dereferencing() it and using the saved.
>>
>>Reported-by: Ding Tianhong <dingtianhong@huawei.com>
>>Fixes: aeea64a ("bonding: don't trust arp requests unless active slave
>>really works")
>>CC: Jay Vosburgh <fubar@us.ibm.com>
>>CC: Andy Gospodarek <andy@greyhouse.net>
>>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> 
> Sorry David, it should have been net-next (I've based it on the
> net-next
> tree).
> 
> Can you apply it to net-next or should I resend it?
> 
> Sorry for the noise.

It's fine, applied to net-next, thanks.
