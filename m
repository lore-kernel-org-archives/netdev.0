From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] net-2.6 : fix dev_get_valid_name
Date: Tue, 18 May 2010 21:55:05 +0200
Message-ID: <4BF2F099.8000704@free.fr>
References: <1274204112-8920-1-git-send-email-daniel.lezcano@free.fr> <20100518105451.05b060e8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, opurdila@ixiacom.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:39856 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171Ab0ERTzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 15:55:09 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.1/8.13.1) with ESMTP id o4IJt8oL028980
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 19:55:08 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4IJt89j1216608
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 21:55:08 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4IJt7e4007827
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 21:55:07 +0200
In-Reply-To: <20100518105451.05b060e8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2010 07:54 PM, Stephen Hemminger wrote:
> On Tue, 18 May 2010 19:35:12 +0200
> Daniel Lezcano<daniel.lezcano@free.fr>  wrote:
>
>    
>> +static int dev_get_valid_name(struct net_device *dev, const char *name, bool fmt)
>>   {
>> +	struct net *net;
>> +
>> +	BUG_ON(!dev_net(dev));
>> +	net = dev_net(dev);
>>      
> This is not really part of the same fix. And not sure why it is added here?
>    

I could have created a temporary buffer within the function and have 
passed it to __dev_alloc_name but this is exactly what does 
'dev_alloc_name'.
So 'dev_alloc_name' replaces '__dev_alloc_name' but takes a 'dev' 
parameter which is not passed to 'dev_get_valid_name'.
Instead of passing an extra parameter 'dev', I just replaced the 'net' 
parameter by the 'dev' parameter and extracted the 'net' pointer from it.

I have a few patches cleaning up these functions and the callers but I 
prefer to send them against net-next-2.6.
