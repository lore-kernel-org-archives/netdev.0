From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: ipv6: Remove addresses for failures with strict DAD
Date: Wed, 17 Aug 2016 17:08:42 +0100
Message-ID: <ae4a3e5a-1b36-5eab-da03-d6121abb6223@brocade.com>
References: <1471429720-6141-1-git-send-email-mmanning@brocade.com>
 <58750abf-9221-f2d3-0fb2-cc5f1bcd92f9@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:33783 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752774AbcHQQdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 12:33:01 -0400
In-Reply-To: <58750abf-9221-f2d3-0fb2-cc5f1bcd92f9@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2016 04:40 PM, Hannes Frederic Sowa wrote:
> On 17.08.2016 12:28, Mike Manning wrote:
>> +static void dev_disable_change(struct inet6_dev *idev);
>>  
>>  /*
>>   *	Configured unicast address hash table
>> @@ -1945,6 +1946,12 @@ lock_errdad:
>>  
>>  			pr_info("%s: IPv6 being disabled!\n",
>>  				ifp->idev->dev->name);
>> +			spin_unlock_bh(&ifp->lock);
>> +			addrconf_dad_stop(ifp, 1);
>> +			rtnl_lock();
>> +			dev_disable_change(idev);
>> +			rtnl_unlock();
>> +			return;
>>  		}
>>  	}
> 
> You can't take rtnl_lock at that point but must postpone the actions and
> do that in addrconf_dad_work.
> 
> Probably the whole ... else if (idev->cnf.accept_dad > 1 && ...) needs
> to move there.
> 
> Bye,
> Hannes
> 
> 

Thanks for the prompt review, I will look into making these changes.

Also these changes caused a build error due to conditional compilation without CONFIG_SYSCTL, which is resolved by replacing the call to dev_disable_change(idev) by directly calling addrconf_ifdown(idev->dev, 0) instead.

I would appreciate any further comments if the suggested change in behavior is not acceptable.

Thanks
Mike
