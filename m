From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Allow 'ip' to run in daemon mode?
Date: Thu, 01 Jul 2010 08:41:45 -0700
Message-ID: <4C2CB739.3020001@candelatech.com>
References: <4C2A1291.7000203@candelatech.com> <20100701070753.GA15216@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54368 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756589Ab0GAPl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 11:41:59 -0400
In-Reply-To: <20100701070753.GA15216@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2010 12:07 AM, Simon Horman wrote:
> On Tue, Jun 29, 2010 at 08:34:41AM -0700, Ben Greear wrote:
>> I'm considering modifying 'ip' to be able to run in daemon
>> mode so that I can do lots of IP commands without having to
>> pay the startup cost of iproute.
>>
>> The -batch option almost works, but it's hard to programatically
>> figure out failure codes.
>>
>> I'm thinking about making these changes:
>>
>> 1)  Move all of the error printing code into common methods (basically,
>>     wrap printf).  In daemon mode this text can be sent back to the
>>     calling process, and in normal mode, it will be printed to stdout/stderr
>>     as it is currently.
>>
>> 2)  Remove all or most calls to 'exit' and instead return error codes
>>     to the calling logic.
>>
>> 3)  Add ability to listen on a unix socket for commands, basically treat
>>     them just like batch commands, one command per packet.
>>
>> 4)  Return well formatted error code and text response to calling process
>>     over the unix socket, maybe something like:
>>
>> RV: [errno or equiv, zero for success]\n
>> CMD: [ command string this relates to ]\n
>> [ Optional free form text ]
>>
>>
>> Does something like this have any chance of upstream inclusion?
>
> Hi Ben,
>
> can't you achieve as much by omitting 3) and using stdio (cleanly)?
> Or in other words, fix batch mode rather than adding another mode.
> Or are you worried about backwards-compatibility?

I think the most of the work will be in steps 1 and 2.  Adding a listening
socket and dealing with that is probably 50-100 lines of code.

I'd be happy to attempt steps 1, 2, and possibly 4 for standard iproute2.
If the unix socket thing still isn't wanted, it would be relatively easy for me
to carry a patch to enable it in my own code.

I think a lot of folks are scraping the output of 'ip', so backwards compat of
the error messages is a concern.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
