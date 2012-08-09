From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/19] netfilter: IPv6 NAT
Date: Thu, 9 Aug 2012 23:52:14 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208092347080.26308@stinky-local.trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
 <87a9y3n5rz.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33187 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759760Ab2HIVwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 17:52:16 -0400
In-Reply-To: <87a9y3n5rz.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Aug 2012, Eric W. Biederman wrote:

> kaber@trash.net writes:
>
>> The following patches contain an updated version of IPv6 NAT against
>> Linus' current tree.
>>
>> The series is organized as follows:
>>
>> - Patches 01-03 contain bugfixes for SIP helper bugs/regressions
>>   present in the current kernel
>
> Why not just delete this code?  The current best practices are to
> disable ALGs for SIP.  To the point in some circles people recommend
> running SIP over TLS to avoid over helpful NAT ALGs.

And where can I read up on these best practices and how well they work?

In any case, these patches are all for the connection tracking helper,
which is needed unless you want to open up your firewall for every 
possible RTP source, in which case you can simply disable it. Some people 
are also using it to proritize RTP streams without any filtering.

Also, even if the NAT helper would not mangle packets, it is still needed 
to adjust expectations. so incoming connections can go to the correct
destination. That is, direct RTP connections between two endpoints
that didn't have any direct signalling communication before

You can of course also proxy everything through your SIP provider 
(including internal calls) and/or use STUN (which is unreliable under
Linux). I prefer not to.
