From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] Add new timeval_to_sec function
Date: Tue, 24 Jul 2007 12:10:28 +0530
Message-ID: <46A59EDC.4060906@linux.vnet.ibm.com>
References: <20070723101159.32ef3bdd.varunc@linux.vnet.ibm.com> <46A48FFD.4070902@trash.net> <46A57CF3.6040505@linux.vnet.ibm.com> <46A59AAF.6090605@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	sri@us.ibm.com, dlstevens@us.ibm.com, varuncha@in.ibm.com,
	Thomas Gleixner <tglx@linutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:36066 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753672AbXGXGkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 02:40:25 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6O5a9l9011755
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 01:36:09 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6O6eKuk450204
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 02:40:20 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6O6eJ2A020455
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 02:40:19 -0400
In-Reply-To: <46A59AAF.6090605@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> Varun Chandramohan wrote:
>   
>> Patrick McHardy wrote:
>>   
>>     
>>> Varun Chandramohan wrote:
>>>   
>>>     
>>>       
>>>>  /**
>>>> + * timeval_to_sec - Convert timeval to seconds
>>>> + * @tv:         pointer to the timeval variable to be converted
>>>> + *
>>>> + * Returns the seconds representation of timeval parameter.
>>>> + */
>>>> +static inline time_t timeval_to_sec(const struct timeval *tv)
>>>> +{
>>>> +	return (tv->tv_sec + (tv->tv_usec + 500000)/1000000);
>>>> +}
>>>>     
>>>>       
>>>>         
>>> I don't think you should round down timeout values.
>>>   
>>>     
>>>       
>> Can you elaborate on that? As per the RFC of MIB ,we need only seconds
>> granularity. Taking that as the case i dont understand why round down
>> should not be done?
>>   
>>     
>
> When you like to create any timeout based on your calculated value, you
> might run into the problem that your calculated value is set to _zero_
> even if there was "some time" before the conversion. This might probably
> not what you indented to get.
>
> So what about rounding up with
>
> return (tv->tv_sec + (tv->tv_usec + 999999)/1000000);
>
> ???
>
>   
This can done.  Is this what you were ref to me, Patrick?
> Btw. isn't here already any solution based on ktime conversions?
>
>   
AFAIK there isint any conversion function to secs. Correct me if iam wrong.
But we can have a function or macro to do this conversion.
> Regards,
> Oliver
>
>
>   
Regards,
Varun
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

