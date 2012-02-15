From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Wed, 15 Feb 2012 16:10:37 +0400
Message-ID: <4F3BA0BD.9010501@msgid.tls.msk.ru>
References: <4F33FC0E.4020701@msgid.tls.msk.ru> <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F341283.1020904@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:54247 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752250Ab2BOMKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 07:10:40 -0500
In-Reply-To: <4F341283.1020904@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.02.2012 22:37, Michael Tokarev wrote:
> On 09.02.2012 21:45, Eric Dumazet wrote:
[]
>> Did you try to apply by hand commits :
>>
>> 7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae   // added in 3.2
>> (route: fix ICMP redirect validation)
>>
>> and
>> 9cc20b268a5a14f5e57b8ad405a83513ab0d78dc
>> (ipv4: fix redirect handling)
>
> I haven't tried anything yet, as mentioned above: this prob
> just appeared today, out of the sudden, and what's the most
> important (imho) is that I can not reproduce it.  The host
> hasn't been rebooted, I were thinking about maybe some
> experiments with it before doing anything else.
>
> But I blocked this specific IP address on the gateway and the
> cached entry expired after 10 minutes (that host tried to
> check mail every minute so no doubt the inactivity timer
> never triggered).  So at least one difference in behavour is
> now gone.
>
> What bothers me more are 3 other issues I see around this:
>
> 1. Why this specific IP were cached to start with?  I don't
>    expect any ICMP redirects for that network at all, and no
>    spoofing or malicious traffic either.
>
> 2. I can't reproduce the issue while forcing ICMP redirects.
>   Maybe my original prob was not due to a redirect but due to
>   something else?  I dunno.
>
> 3. Why it affects whole host and all numerous different/separate
>   network namespaces on it?  _All_ lxc containers started thinking
>   this IP is reachable on the local subnet, at once, even those
>   who never ever tried to send any packets to that IP before!

Do you have any insight about all this?  That smells.. fishy
somehow.  Or maybe not, since all lxc guests here are connected
to the same bridge on the host, so it is the host who does the
bad thing, apparently, hence affecting all the guests (guest
routes packets over veth to host which does further bridging/routing).

> And in another email you wrote:
>
>> David is currently working on backporting to 3.0 all necessary fixes for
>> this exact problem.

David, any progress with these?

7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae "route: fix ICMP redirect validation"
applies correctly to 3.0, but 9cc20b268a5a14f5e57b8ad405a83513ab0d78dc
"ipv4: fix redirect handling" does not, due to some changes in-between,
but these should be easy to sort out.  Should I perhaps refresh this
patch myself?  It should be doable, I think.

Thank you!

/mjt
