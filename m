From: Ben Greear <greearb@candelatech.com>
Subject: Re: source route ignored in favor of local interface
Date: Wed, 02 Mar 2011 10:55:09 -0800
Message-ID: <4D6E928D.6030806@candelatech.com>
References: <loom.20110301T154947-689@post.gmane.org> <4D6D4370.5040308@genband.com> <4D6D49AE.2030303@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>, netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44748 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756065Ab1CBSzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 13:55:18 -0500
In-Reply-To: <4D6D49AE.2030303@cox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/2011 11:31 AM, Joe Buehler wrote:
>> If you really want to modify things, have you looked at your ip rules?
>> "ip ru" will dump them.  Typically it looks something like
>>
>> 0:      from all lookup local
>> 32766:  from all lookup main
>> 32767:  from all lookup default
>>
>> The last item in each row is the name of the routing table.  As you can
>> see, the first rule is for local interfaces, and a later rule deals with
>> the main and default routing tables.
>>
>> You could move the local lookup to rule 1 and add in a new rule 0
>> specifically dealing with your situation.
>
> We have tried some variations on modifications to ip rules, but the
> kernel appears to treat rule 0 specially -- it cannot be deleted, for
> example.  This results in the enforcing of local interfaces before
> source routes -- surely something that should be a policy decision, not
> hard-coded.
>
> Let me rephrase and ask: Does anyone know how to replace the priority 0
> rule?

You can do this on more modern kernels (2.6.36 and later definately works..not sure
about earlier).

		ip rule add pref 512 lookup local
		ip rule del pref 0 lookup local

Thanks,
Ben

>
> Joe Buehler
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

