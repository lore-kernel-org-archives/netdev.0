From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a tasklet from ldc_rx path
Date: Tue, 12 Aug 2014 23:37:37 -0700
Message-ID: <4353FF5D-2E9B-4CBF-89C7-335EA595B40B@oracle.com>
References: <8BE2AE04-EF39-45A0-9AB4-15F5160C1449@oracle.com> <20140812.222941.2255442432293393813.davem@davemloft.net> <FBAD5ADB-C4DB-40A9-975F-F2E1304AB2DC@oracle.com> <20140812.231104.1011316861471226204.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32650 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaHMGhl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 02:37:41 -0400
In-Reply-To: <20140812.231104.1011316861471226204.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Aug 12, 2014, at 11:11 PM, David Miller <davem@davemloft.net> wrote:

> From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
> Date: Tue, 12 Aug 2014 22:44:27 -0700
> 
>> Thanks, if there is a method to accomplish this with multiple Tx netdev queues
>> would be wonderful. We will research on the custom ndo_selec_queue()
>> method to direct traffic automatically at the network stack level.
>> We probably also need to look for methods to increase parallelism to boost
>> performance, I assume multiple Tx queues would be a method to accomplish
>> that as well.
> 
> It will introduce parallelism only when there is traffic to multiple
> peers at the same time.

Yes, I should not have related these two things, especially without
proper experimentation. In other implementations, we have used 
techniques such as multiple  Tx queues to increase parallelism but 
path selection is done within the driver to get the benefit of the parallelism for all peers.
We need to see what method suites best for sunvnet, we hope to know
more once we investigate all methods available. 

In case of custom ndo_select_queue() method, we need to see if there
are methods to deal with ports dynamically added/removed too. 

-Raghuram