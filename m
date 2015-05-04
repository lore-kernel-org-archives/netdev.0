From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] core: Correct an over-stringent device loop detection.
Date: Mon, 04 May 2015 15:55:48 -0400
Message-ID: <5547CEC4.3060204@redhat.com>
References: <1430616824-9006-1-git-send-email-vyasevic@redhat.com> <20150504.145815.2274500932397440771.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpirko@redhat.com, vfalico@gmail.com
To: David Miller <davem@davemloft.net>, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252AbbEDTzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 15:55:49 -0400
In-Reply-To: <20150504.145815.2274500932397440771.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2015 02:58 PM, David Miller wrote:
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Sat,  2 May 2015 21:33:44 -0400
> 
>> The code in __netdev_upper_dev_link() has an over-stringent
>> loop detection logic that actually prevents valid configurations
>> from working correctly.
>>
>> In particular, the logic returns an error if an upper device
>> is already in the list of all upper devices for a given dev.
>> This particular check seems to be a overzealous as it disallows
>> perfectly valid configurations.  For example:
>>   # ip l a link eth0 name eth0.10 type vlan id 10
>>   # ip l a dev br0 typ bridge
>>   # ip l s eth0.10 master br0
>>   # ip l s eth0 master br0  <--- Will fail
>>
>> If you switch the last two commands (add eth0 first), then both
>> will succeed.  If after that, you remove eth0 and try to re-add
>> it, it will fail!
>>
>> It appears to be enough to simply check adj_list to keeps things
>> safe.
>>
>> I've tried stacking multiple devices multiple times in all different
>> combinations, and either rx_handler registration prevented the stacking
>> of the device linking cought the error.
>>
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> 
> Applied, thanks Vlad.
> 

Hi Dave

Can you also queue it for stable.  This has been broken for a while.
Thanks
-vlad
