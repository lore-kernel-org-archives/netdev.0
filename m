From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 2/4] Add new timeval_to_sec function
Date: Tue, 24 Jul 2007 08:22:39 +0200
Message-ID: <46A59AAF.6090605@hartkopp.net>
References: <20070723101159.32ef3bdd.varunc@linux.vnet.ibm.com> <46A48FFD.4070902@trash.net> <46A57CF3.6040505@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	sri@us.ibm.com, dlstevens@us.ibm.com, varuncha@in.ibm.com,
	Thomas Gleixner <tglx@linutronix.de>
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cg-p07-fb.rzone.de ([81.169.146.215]:40451 "EHLO
	cg-p07-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbXGXGYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 02:24:38 -0400
Received: from mo-p00-ob.rzone.de (mrclete-mo-p00-ob.mail [192.168.63.64])
	by gibbsson-fb-07.store (RZmta 4.6) with ESMTP id G03ec4j6O5h5DV
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 08:24:36 +0200 (MEST)
In-Reply-To: <46A57CF3.6040505@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Varun Chandramohan wrote:
> Patrick McHardy wrote:
>   
>> Varun Chandramohan wrote:
>>   
>>     
>>>  /**
>>> + * timeval_to_sec - Convert timeval to seconds
>>> + * @tv:         pointer to the timeval variable to be converted
>>> + *
>>> + * Returns the seconds representation of timeval parameter.
>>> + */
>>> +static inline time_t timeval_to_sec(const struct timeval *tv)
>>> +{
>>> +	return (tv->tv_sec + (tv->tv_usec + 500000)/1000000);
>>> +}
>>>     
>>>       
>> I don't think you should round down timeout values.
>>   
>>     
> Can you elaborate on that? As per the RFC of MIB ,we need only seconds
> granularity. Taking that as the case i dont understand why round down
> should not be done?
>   

When you like to create any timeout based on your calculated value, you
might run into the problem that your calculated value is set to _zero_
even if there was "some time" before the conversion. This might probably
not what you indented to get.

So what about rounding up with

return (tv->tv_sec + (tv->tv_usec + 999999)/1000000);

???

Btw. isn't here already any solution based on ktime conversions?

Regards,
Oliver


