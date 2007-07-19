From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] ibmveth: Enable TCP checksum offload
Date: Thu, 19 Jul 2007 08:35:14 -0500
Message-ID: <469F6892.2020908@linux.vnet.ibm.com>
References: <11846854701127-patch-mail.ibm.com> <469E9510.7060703@garzik.org>
Reply-To: brking@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, rcjenn@linux.vnet.ibm.com,
	santil@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:49997 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757624AbXGSNfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 09:35:17 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6JDZGW2012157
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 09:35:16 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6JDZG2g535876
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 09:35:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6JDZFu8026120
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 09:35:16 -0400
In-Reply-To: <469E9510.7060703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Brian King wrote:
>> This patchset enables TCP checksum offload support for IPV4
>> on ibmveth. This completely eliminates the generation and checking of
>> the checksum for packets that are completely virtual and never
>> touch a physical network. A simple TCP_STREAM netperf run on
>> a virtual network with maximum mtu set yielded a ~30% increase
>> in throughput. This feature is enabled by default on systems that
>> support it, but can be disabled with a module option.
>>
>> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
> 
> this should be controllable purely via ethtool...

I'll remove the module parameter and resend.

>>  struct ibmveth_rx_q_entry {
>>      u16 toggle : 1;
>>      u16 valid : 1;
>> -    u16 reserved : 14;
>> +    u16 reserved : 4;
>> +    u16 no_csum : 1;
>> +    u16 csum_good : 1;
>> +    u16 reserved2 : 8;
>>      u16 offset;
> 
> As a general rule, it would be nice to start moving away from bitfields 
> in this driver

I'll take a look at that for a future cleanup patch.

Thanks,

Brian

-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center
