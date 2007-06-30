From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/3] NetXen: Graceful teardown of interface and hardware
 upon module unload
Date: Sat, 30 Jun 2007 18:43:13 -0400
Message-ID: <4686DC81.5090908@garzik.org>
References: <20070630203844.256007454@netxen.com> <20070630204424.876510236@netxen.com> <200707010012.11527.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dhananjay.phadke@gmail.com, netdev@vger.kernel.org, rob@netxen.com,
	Milan Bag <mbag@netxen.com>, Wen Xiong <wenxiong@us.ibm.com>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38811 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027AbXF3WnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 18:43:18 -0400
In-Reply-To: <200707010012.11527.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Saturday 30 June 2007 22:38:47 dhananjay.phadke@gmail.com wrote:
>> These changes allow driver close routine to be called during module unload,
>> to clean-up buffers and other software resources, flush queues etc. Also,
>> hardware is reset to pristine state. 
>>
>> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
>> Signed-off-by: Milan Bag <mbag@netxen.com>
>> Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>
> 
>>  		off = netxen_nic_pci_set_window(adapter, memaddr);
>>  		addr = pci_base_offset(adapter, off);
>>  		writel(data, addr);
>> +		do {
>> +			if (readl(addr) == data)
>> +				break;
>> +			msleep_interruptible(100);
> 
> If you use msleep_interruptible(), I'd say you should check for
> the return value of that call and probably abort firmware
> processing here if a signal interrupted us.

While strictly this is true, I strongly urge the use of 
non-interruptible sleeps when used in hardware-related delays.  Very 
rarely does one really want to care about signals for such cases.

	Jeff


