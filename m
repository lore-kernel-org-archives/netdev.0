From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Mon, 03 Jul 2006 11:38:06 +0200
Message-ID: <44A8E57E.4080805@trash.net>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <44A8E211.4090005@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, greearb@candelatech.com,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:24279 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750983AbWGCJjT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 05:39:19 -0400
To: netdev@vger.kernel.org
In-Reply-To: <44A8E211.4090005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Patrick McHardy wrote:
> 
>>I took on Ben's challenge to increase the number of possible routing tables,
>>these are the resulting patches.
>>
>>The table IDs are changed to 32 bit values and are contained in a new netlink
>>routing attribute. For compatibility rtm_table in struct rtmsg can still be
>>used to access the first 255 tables and contains the low 8 bit of the table
>>ID in case of dumps. Unfortunately there are no invalid values for rtm_table,
>>so the best userspace can do in case of a new iproute version that tries to
>>access tables > 255 on an old kernel is to use RTM_UNSPEC (0) for rtm_table,
>>which will make the kernel allocate an empty table instead of silently adding
>>routes to a more or less random table. The iproute patch will follow shortly.
> 
> 
> Actually that last part wasn't entirely true. The last couple of
> releases of the kernel include the inet_check_attr function,
> which (unwillingly) breaks with the tradition of ignoring
> unknown attributes and signals an error on receiving the RTA_TABLE
> attribute. So the iproute patch only includes the RTA_TABLE
> attribute when the table ID is > 255, in which case rtm_table
> is set to RT_TABLE_UNSPEC. Old kernels will still have the
> behaviour I described above. The patch has been tested to
> behave as expected on both patched and unpatched kernels.

That wasn't entirely true either, its not inet_check_attr but
rtnetlink_rcv_message that aborts, and it does this on all
kernels. Somehow I thought unknown attributes were usually
ignored .. anyway, this is a good thing in this case as it
will avoid unexpected behaviour and simply return an error
on kernels where this feature is not available.

