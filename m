From: Nikolay Borisov <kernel@kyup.com>
Subject: Re: [PATCH 0/4] Namespacify inet_peer_* sysctl knobs
Date: Thu, 18 Feb 2016 17:04:12 +0200
Message-ID: <56C5DD6C.1050504@kyup.com>
References: <1455703798-15258-1-git-send-email-kernel@kyup.com>
 <87si0r4086.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38576 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426020AbcBRPEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 10:04:15 -0500
Received: by mail-wm0-f48.google.com with SMTP id a4so29531273wme.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 07:04:14 -0800 (PST)
In-Reply-To: <87si0r4086.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/17/2016 09:15 PM, Eric W. Biederman wrote:
> Nikolay Borisov <kernel@kyup.com> writes:
> 
>> This series make the inet_peer ttl sysctls to be namespace aware. 
>>
>> Patch 1 adds a namespace association to the inet_peer_base struct, 
>> which in turn is used to make the sysctls namespace aware. The 
>> rest of the patches are straightforward.
> 
> At a quick skim I am not certain I am comfortable with this change.
> 
> The issue is that these are not packet parameters you are tuning but
> lifetimes for data structures.

Right, I though the inet peer expiration might have repercussion on the
way the networking stack worked. But apparently that's not case.
> 
> Generally there are challenges making this kind of thing per namespace
> because resource control can lead to DOS attack from one namespace
> being able to arbitrarly control it's own resource consumption.
> 
> Is this something that is actually worth making per namespace?

I guess the series can be dropped if it's deemed unnecessary.


> 
> Eric
> 
>> Nikolay Borisov (4):
>>   inetpeer: Add net namespace assosication in inet_peer_base
>>   inetpeer: Namespacify inet_peer_maxttl sysctl knob
>>   inetpeer: Namespacify inet_peer_minttl sysctl knob
>>   inetpeer: Namespacify inet_peer_threshold sysctl knob
>>
>>  include/net/inetpeer.h     |  1 +
>>  include/net/ip.h           |  5 -----
>>  include/net/netns/ipv4.h   |  4 ++++
>>  net/ipv4/inetpeer.c        | 15 ++++++---------
>>  net/ipv4/route.c           |  1 +
>>  net/ipv4/sysctl_net_ipv4.c | 47 ++++++++++++++++++++++++----------------------
>>  6 files changed, 37 insertions(+), 36 deletions(-)
