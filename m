From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net RESEND] bonding: don't change to 802.3ad mode while
 ARP monitoring is running
Date: Mon, 18 Nov 2013 15:48:38 -0500 (EST)
Message-ID: <20131118.154838.776189725378131169.davem@davemloft.net>
References: <528710F7.7050207@huawei.com>
	<1384796682.4774.26.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com, vfalico@redhat.com, netdev@vger.kernel.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab3KRUsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 15:48:42 -0500
In-Reply-To: <1384796682.4774.26.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Mon, 18 Nov 2013 11:44:42 -0600

> On Sat, 2013-11-16 at 14:30 +0800, Ding Tianhong wrote:
>> Because the ARP monitoring is not support for 802.3ad, but I still
>> could change the mode to 802.3ad from ab mode while ARP monitoring
>> is running, it is incorrect.
>> 
>> So add a check for 802.3ad in bonding_store_mode to fix the problem,
>> and make a new macro BOND_NO_USES_ARP() to simplify the code.
> 
> Instead of failing, couldn't the code stop ARP monitoring and allow the
> mode change?  This is similar to setting miimon, which disables ARP
> monitoring, or setting ARP monitoring, which disables miimon.
> 
> 	if (new_value && bond->params.arp_interval) {
> 		pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
> 			bond->dev->name);
> 		bond->params.arp_interval = 0;
> 		if (bond->params.arp_validate)
> 			bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
> 	}
> 
> Bond mode is the most important bond option, so it seems like it should
> override any of the other sub-options.  I know the code doesn't do this
> now, but maybe instead of the patch you propose, it would be nicer to
> allow the mode change instead?

I agree with Dan, if other mode changes behave this way (by dropping the
incompatible feature) we should make 802.3ad do so as well at the very
least for consistency.
