From: Ben Greear <greearb@candelatech.com>
Subject: Re: PF_RING: Include in main line kernel?
Date: Thu, 15 Oct 2009 09:33:53 -0700
Message-ID: <4AD74EF1.6080106@candelatech.com>
References: <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org> <20091014203640.GB32317@ioremap.net> <4AD64251.50903@candelatech.com> <20091014.144923.112167161.davem@davemloft.net> <20091015070234.GA29506@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, deri@ntop.org,
	shemminger@vyatta.com, brad.doctor@gmail.com,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39876 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932872AbZJOQfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 12:35:13 -0400
In-Reply-To: <20091015070234.GA29506@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/2009 12:02 AM, Evgeniy Polyakov wrote:
> On Wed, Oct 14, 2009 at 02:49:23PM -0700, David Miller (davem@davemloft.net) wrote:
>>> Maybe something similar to the attached patch?
>>
>> This is not something I'm interested in applying.
>>
>> It makes implementing proprietary complete networking stacks
>> for Linux way too easy.
>
> Such kernels will be tainted and thus its bugs and problems will be
> clearly indicated by the proprietary module.
>
>> Instead I'd rather have a GPL exported function that allows indication
>> of consumption somehow.  That's why we have a special hook for
>> bonding, so it cannot be abused in proprietary modules.
>
> I believe bonding with its hook is a historical heritage and priority
> absence in packet hooks which do not currently allow something to be
> registered very first and steal packets from the stack.
>
> Looks like bonding could be implemented as a packet handler with Ben's
> patch applied, isn't it?

Bonding, bridging, mac-vlans, pktgen-rx logic, sniffers, and others could.  The only trick is
ordering...it may be better to keep the hard-coded hooks in a definite
order than to allow users to switch them around.

Or, could have a precedence value when adding hooks (protocols) so that modules
can properly order themselves by default, but users *could* reorder
them if they really wanted to (might be useful to have mac-vlans before
bonding some of the time, and after it others, for instance...)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

