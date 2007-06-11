From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Support send-to-self over external interfaces (and veths).
Date: Mon, 11 Jun 2007 08:52:50 -0700
Message-ID: <466D6FD2.1020206@candelatech.com>
References: <4669ED81.8060800@candelatech.com> <466D4165.2090506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:39800 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001AbXFKPwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 11:52:53 -0400
In-Reply-To: <466D4165.2090506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Ben Greear wrote:
>   
>> This should also be useful with the pending 'veth' driver, as it
>> emulates two ethernet ports connected with a cross-over cable.
>>
>> To make this work, you have to enable the sysctl (look Dave,
>> no IOCTLS, there might be hope for me yet!! :)), and in your
>> application you will need to use SO_BINDTODEVICE (and probably bind to
>> the local IP as well).  Some applications such as traceroute already
>> support this binding..others such as ping do not.
>>
>> You most likely will also have to set up routing tables using
>> source IPs as a rule to direct these connections to a particular
>> routing table.
>>
>> Comments welcome.
>>     
>
>
> I would really prefer to simply make the prio 0 "lookup local"
> rule deletable so you can rules with higher priority. That
> allows to do send to self without any further code changes
> and avoids the need to bind applications to a device.
>   
I am not against making that change as well, but it is often easier to 
just bind-to-device
than to set up specific host routes for every possible combination..as 
it appears your
method requires.  (I could have mis-understood the routing requirements, 
but it seemed to
if you wanted any 100 interfaces to send to any other, your method would 
required 100 * 100
routes.)

A decent set of programs already support bind-to-device, and others are 
easily patched
if they need the behaviour.

Thanks,
Ben


> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


