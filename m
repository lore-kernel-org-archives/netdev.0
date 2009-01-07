From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH -net-next 3/4] firmware: convert tg3 driver to	request_firmware()
Date: Wed, 07 Jan 2009 10:31:23 +0100
Message-ID: <4964766B.2080105@hartkopp.net>
References: <1230626497.24796.26.camel@jaswinder.satnam> <49620AFE.6040409@hartkopp.net> <20090105.160112.119906029.davem@davemloft.net> <20090107031724.GA6118@porter.dyn.128.marineau.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jaswinder@infradead.org,
	jgarzik@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	mchan@broadcom.com
To: Michael Marineau <mike@marineau.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090107031724.GA6118@porter.dyn.128.marineau.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Marineau wrote:
> On Mon, Jan 05, 2009 at 04:01:12PM -0800, David Miller wrote:
>   
>> From: Oliver Hartkopp <oliver@hartkopp.net>
>> Date: Mon, 05 Jan 2009 14:28:30 +0100
>>
>>     
>>> 2. I got this inconsistent lock state, i've not seen before:
>>>       
>> I know what causes it.  It's this change:
>>
>> commit 22604c866889c4b2e12b73cbf1683bda1b72a313
>> Author: Michael Marineau <mike@marineau.org>
>> Date:   Sun Jan 4 17:18:51 2009 -0800
>>
>>     net: Fix for initial link state in 2.6.28
>>
>> It causes us to now call the linkwatch even trigger code inside of
>> software interrupt context, but that is illegal because that code path
>> takes the dev_base_lock rwlock as a writer.
>>
>> I'm going to revert, and Michael will need to find a way to fix the
>> initial link state issue without adding locking problems :-)
>>     
>
> Ok, here's another try. Rather than find a safer way to sync up the
> operstate variable with the normal state flags I decided to just nuke
> operstate entirely, it just duplicated what was already in the state
> flags for the most part. 

Hi Michael,

i just compiled my current net-2.6 with your new patch and had no 
problems booting my machine afterwards.

Holding the relevant information in one place looks like a good approach 
to me even though i did not test the functionality in detail.

Thanks,
Oliver
