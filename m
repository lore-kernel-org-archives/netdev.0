From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/2 v2] af-packet:  Use existing netdev reference for
 bound sockets.
Date: Thu, 26 May 2011 21:11:15 -0700
Message-ID: <4DDF2463.3020001@candelatech.com>
References: <1306454141-1634-1-git-send-email-greearb@candelatech.com> <1306467745.2543.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52920 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777Ab1E0ELS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 00:11:18 -0400
In-Reply-To: <1306467745.2543.60.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2011 08:42 PM, Eric Dumazet wrote:
> Le jeudi 26 mai 2011 =C3=A0 16:55 -0700, greearb@candelatech.com a =C3=
=A9crit :

>>   out_free:
>>   	kfree_skb(skb);
>>   out_unlock:
>> -	if (dev)
>> +	if (dev&&  need_rls_dev)
>>   		dev_put(dev);
>>   out:
>>   	return err;
>
> Hmmm, I wonder why you want this Ben.
>
> IMHO this is buggy, because we can sleep in this function.
>
> We must take a ref on device (its really cheap these days, now we hav=
e a
> percpu device refcnt)

Why must you take the reference?  And if we must, why isn't the
current code that assigns the prot_hook.dev without taking a
reference OK?

It seems a waste to do the lookup and free if we don't have to,
and with thousands of devices, the lookup might take a reasonable
amount of effort?

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
