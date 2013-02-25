From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: Disable IPv4-mapped - enforce IPV6_V6ONLY
Date: Mon, 25 Feb 2013 15:47:59 +0100
Message-ID: <512B799F.6080009@ahsoftware.de>
References: <51278CF6.2060402@ahsoftware.de> <51292A2B.3000304@ahsoftware.de> <512B4EAF.2050301@linux-ipv6.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7168@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:52851 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab3BYOsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 09:48:14 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7168@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 25.02.2013 14:23, schrieb David Laight:
>>> A proper solution would be to either return false if net.ipv6.bindv6only is true and optval is false
>> (which would break downward compatibility because it wouldn't just be a default and setsockopt might
>> return an error) or to introduce a new sysctl variable like net.ipv6.bindv6only_enforced_silently.
>> ("silently" because setsockopt() wouldn't return an error if net.ipv6.bindv6only is true and optval
>> (v6only in the example above) is false.)
>>>
>>> I would volunteer to write a patch which introduces something like
>> net.ipv6.bindv6only_enforced_silently if some maintainer would give me his ok.
>>>
>>> If so, the question remains if
>>>
>>> systemctl net.ipv6.bindv6only_enforced_silently = 1
>>>
>>> should set systemctl.net.ipv6.bindv6only too or if an error should be returned if
>> net.ipv6.bindv6only is false.
>>
>> I am not convinced why you need this, and I am not in favor of
>> enfocing IPV6_V6ONLY, but... some points:

It's some kind of security feature I want to have. I just don't want to 
search for applications which are listening on IPv4 ports (too) even 
when only IPv6 was configured. There exists several of them.

>>
>> - We should allow system-admin to "enforce" IPV6_V6ONLY to 0 as well.
>> - CAP_NET_ADMIN users should always be able to use both modes
>>    (They can do sysctl anyway.)
>> - setsockopt should fail w/ EPERM if user tries to override.
>
> I can imagine that some programs will always try to clear IPV6_V6ONLY
> (maybe for portability with other OS which default to setting it
> for security reasons) and will error-exit if it fails.
> So non-silent enforcing could be a PITA.

Exactly.

> You really don't want to (globally) stop an application setting
> IPV6_V6ONLY, such a program may well be creating separate IPv4
> and IPv6 sockets.

Agreed. Applications which are setting IPV6_V6ONLY to true usually do 
know what they are doing. But some braindead (configured) applications 
are disabling it (and would bail out if setsockopt() would return an error).

>
> Some of this needs to be part of some application wide 'security'
> framework - that probably doesn't exist!
>
> Should there also be similar controls for the use of IPv4
> mapped addresses in actual on-the-wire IPv6 packets - eg those
> destined for a remote gateway on an IPv6 only system?

I think that can be handled by iptables by just blocking e.g. 
::ffff:0:0/96 and  ::0/96.

But it's a pain to find and take care of apps which are ignoring the 
default (net.ipv6.bindv6only) and are disabling IPV6_V6ONLY explicit for 
whatever reason.

Therefor I would like to have that 
net.ipv6.bindv6only_enforced_silently. Disabling IPv4 in general is not 
what I want.

Regards,

Alexander
