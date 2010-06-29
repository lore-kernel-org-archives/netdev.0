From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2:  Allow 'ip addr flush' to loop more than
 10 times.
Date: Tue, 29 Jun 2010 08:04:34 -0700
Message-ID: <4C2A0B82.7020701@candelatech.com>
References: <1277790959-28075-1-git-send-email-greearb@candelatech.com> <50mof7-b9p.ln1@chipmunk.wormnet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Clouter <alex@digriz.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35046 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799Ab0F2PEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 11:04:45 -0400
In-Reply-To: <50mof7-b9p.ln1@chipmunk.wormnet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2010 01:03 AM, Alexander Clouter wrote:
> greearb@gmail.com wrote:
>>
>> The default remains at 10 for backwards compatibility.
>>
>> For instance:
>> # ip addr flush dev eth2
>> *** Flush remains incomplete after 10 rounds. ***
>> # ip -l 20 addr flush dev eth2
>> *** Flush remains incomplete after 20 rounds. ***
>> # ip -loops 0 addr flush dev eth2
>> #
>>
>> This is useful for getting rid of large numbers of IP
>> addresses in scripts.
>>
> Maybe I am missing a trick, but what is wrong with putting this trivial
> logic into the script:
>
> ip addr show ${DEV} | awk '/inet6? / { print $2 }' | xargs -I{} ip addr del '{}' dev ${DEV}

This isn't going to be fast if you have thousands of addresses.

> You can probably speed things up with '-P' too, '-P 2' gives me a huge
> huge speed up for the work I do with 'ip route'.

Where are you using the -P at?  It's not a supported option of 'ip'
as far as I can tell.

> Why the need to cram more functionality and options into iproute when
> it is something that can be pushed into the wrapper script?

Speed and ease of use.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
