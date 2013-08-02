From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] bonding: fix arp monitoring with vlan slaves
Date: Sat, 03 Aug 2013 00:40:48 +0200
Message-ID: <51FC3570.4020102@redhat.com>
References: <1375461665-4186-1-git-send-email-nikolay@redhat.com> <20130802.153212.1340051334413929810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573Ab3HBWky (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 18:40:54 -0400
In-Reply-To: <20130802.153212.1340051334413929810.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2013 12:32 AM, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@redhat.com>
> Date: Fri,  2 Aug 2013 18:41:05 +0200
> 
>> From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
>>
>> When arp monitoring is enabled the bonding relies on slaves'
>> dev_trans_start() value to check if the slave link is up or not, but for
>> 8021q devices that value is either stale or 0, and can't be used. So use
>> the 8021q's underlying device value.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> Handling this specially in bonding isn't really ideal.
> 
Indeed, it's not really a bonding problem.

> Please either hide this detail in dev_trans_start(), or (preferrably)
> have vlan_dev_hard_start_xmit() set the trans_start timestamp
> properly thus making this just work for everything.
> 
> Thanks.
> 
Yep, I prefer option 2 as well. I will submit a patch tomorrow, thank you
for the suggestions.

Nik
