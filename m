From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Intel-wired-lan] [PATCH 1/3 net-next] e1000: Allocate pm_qos_req
 as needed
Date: Fri, 10 Apr 2015 10:01:59 +0200
Message-ID: <55278377.8030505@iogearbox.net>
References: <cover.1428622095.git.tgraf@suug.ch>	 <99ad8b242a65a60e2a76e952b4c91de2b54a0013.1428622095.git.tgraf@suug.ch>	 <1428624503.2729.55.camel@jtkirshe-mobl> <1428640539.2729.67.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36974 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326AbbDJICF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 04:02:05 -0400
In-Reply-To: <1428640539.2729.67.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2015 06:35 AM, Jeff Kirsher wrote:
> On Thu, 2015-04-09 at 17:08 -0700, Jeff Kirsher wrote:
>> On Fri, 2015-04-10 at 01:43 +0200, Thomas Graf wrote:
>>> e1000 is the only driver requiring pm_qos_req, instead of causing
>>> every device to waste up to 240 bytes. Allocate it for the specific
>>> driver.
>>>
>>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
>>> ---
>>>   drivers/net/ethernet/intel/e1000e/netdev.c | 15 +++++++++++----
>>>   include/linux/netdevice.h                  |  2 +-
>>>   2 files changed, 12 insertions(+), 5 deletions(-)
>>
>> Small nitpick, it is e1000e not e1000 that you are modifying.
>
> So other than the patch title and description referencing e1000 instead
> of e1000e, patch looks fine.
>
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Thanks for working towards reducing struct net_device, that's awesome!

Wrt this patch, I'm wondering if that couldn't be pushed down into
struct e1000_adapter entirely?

Looks like e1000e is the only user of this, would save every other
net_device 8 more bytes:

$ git grep -n "\->pm_qos_req" drivers/net/
drivers/net/ethernet/intel/e1000e/netdev.c:3300:                pm_qos_update_request(&adapter->netdev->pm_qos_req, lat);
drivers/net/ethernet/intel/e1000e/netdev.c:3302:                pm_qos_update_request(&adapter->netdev->pm_qos_req,
drivers/net/ethernet/intel/e1000e/netdev.c:4406:        pm_qos_add_request(&adapter->netdev->pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
drivers/net/ethernet/intel/e1000e/netdev.c:4517:        pm_qos_remove_request(&adapter->netdev->pm_qos_req);

Thanks,
Daniel
