From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Hardware capabilities and bonding offload
Date: Mon, 16 Nov 2015 08:10:27 -0800
Message-ID: <5649FFF3.9080401@gmail.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9AA0D643@SJEXCHMB14.corp.ad.broadcom.com> <20151116153032.GC2217@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>,
	Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33465 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbbKPQKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 11:10:40 -0500
Received: by pabfh17 with SMTP id fh17so181951013pab.0
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 08:10:40 -0800 (PST)
In-Reply-To: <20151116153032.GC2217@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-11-16 07:30 AM, Jiri Pirko wrote:
> Mon, Nov 16, 2015 at 10:29:12AM CET, pjonnala@broadcom.com wrote:
>> Hello,
>>
>> I am looking to offload bond interfaces to hardware for forwarding.  Linux allows for configuring 
>> a variety of parameters on bonds or slave interfaces.  Not all configurations can be offloaded to 
>> hardware.  For example, certain hardware cannot support bonds with mode of adaptive load balancing.
>>
>> When such a configuration is provided by user, we have two options at hand (for platforms supporting
>> hardware offloads):
>>
>> 1. Reject the configuration.  
>>
>> 2. Handle the bond interface in software.  In a scenario where this bond interface is part
>> of a bridge interface, for simplicity purpose, all other interfaces in the bridge need to be 
>> handled in software - which results in a very low packet processing performance.
> 
> Although it might sound intriguing to fallback to sw here, it makes no
> sense and user certainly does not want that. For example in case of our
> HW, we have 100gbit forwarding which would be degraded to ~1gbit (for one
> port pair). Another thing is that for some HW this mignt not be even
> possible. In our case it would be very complicated.
> 
> I believe that the correct approach is to let driver decide if the
> configuration is acceptable or not and reject it in case it is not.
> 

+1 I agree the best approach is to throw a hard error and reject
it if there is no mapping on to the hardware. This lets your
management software propagate that error up so you can handle it
correctly at higher levels in the stack.

You could if needed add a bit to enable setup in software only
if that is needed.

Thanks,
John

> 
>>
>> I'm writing to gather feedback on the approach to take, including any other suggestions.
>> We have discussed this briefly in our weekly netdev meeting, and I received votes for
>> option #1.
>>
>> Thanks
>> Prem
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
