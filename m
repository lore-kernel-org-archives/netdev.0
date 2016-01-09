From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 05/10] fm10k: add rtnl lock protection in
 fm10k_io_resume
Date: Sat, 9 Jan 2016 23:44:18 +0100
Message-ID: <56918D42.8030401@stressinduktion.org>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
 <1452352052-27574-6-git-send-email-hannes@stressinduktion.org>
 <20160109215109.GA16810@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:55742 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755999AbcAIWoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 17:44:21 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 44938202AF
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 17:44:21 -0500 (EST)
In-Reply-To: <20160109215109.GA16810@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.01.2016 22:51, Florian Westphal wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
>> index 4eb7a6fa6b0ddc..846d9b731c8c14 100644
>> --- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
>> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
>> @@ -2350,8 +2350,10 @@ static void fm10k_io_resume(struct pci_dev *pdev)
>>   	/* reset clock */
>>   	fm10k_ts_reset(interface);
>>
>> +	rtnl_lock();
>>   	if (netif_running(netdev))
>>   		err = fm10k_open(netdev);
>> +	rtnl_lock();
>
> Hmm.  Looks like copy&paste error :)

Oh, yeah. Thanks, Florian, fixed it up locally.
