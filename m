From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch 2/3] bridge: make bridge support netpoll
Date: Tue, 23 Mar 2010 13:00:59 +0800
Message-ID: <4BA84B0B.3090908@redhat.com>
References: <20100322082059.4967.63492.sendpatchset@localhost.localdomain>	 <20100322082112.4967.5504.sendpatchset@localhost.localdomain>	 <1269297307.3552.23.camel@calx>  <4BA82186.3010204@redhat.com>	 <1269318470.3552.54.camel@calx>  <4BA84607.7030304@redhat.com> <1269319861.3552.87.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269319861.3552.87.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> On Tue, 2010-03-23 at 12:39 +0800, Cong Wang wrote:
>> Matt Mackall wrote:
>>> On Tue, 2010-03-23 at 10:03 +0800, Cong Wang wrote:
>>>> Matt Mackall wrote:
>>>>> On Mon, 2010-03-22 at 04:17 -0400, Amerigo Wang wrote:
>>>>>> Based on the previous patch, make bridge support netpoll by:
>>>>>>
>>>>>> 1) implement the 4 methods to support netpoll for bridge;
>>>>>>
>>>>>> 2) modify netpoll during forwarding packets in bridge;
>>>>>>
>>>>>> 3) disable netpoll support of bridge when a netpoll-unabled device
>>>>>>    is added to bridge;
>>>>> Not sure if this is the right thing to do. Shouldn't we simply enable
>>>>> polling on all devices that support it and warn about the others (aka
>>>>> best effort)?
>>>>>
>>>> I don't think it's a good idea, because we check if a device
>>>> supports netpoll by checking if it has ndo_poll_controller method.
>>> Uh, what? If we have 5 devices on a bridge and 4 support netpoll, then
>>> shouldn't we just send netconsole messages to those 4 devices? Isn't
>>> this much better than simply refusing to work?
>>>
>> How could you let the bridge know netpoll is not sent to
>> the one that doesn't support netpoll during setup? This will
>> be complex, I am afraid.
> 
> I thought I saw a simple loop over bridge devices at poll time in your
> patch. So it should be a simple matter of skipping unsupported devices
> in that loop.

Nope, we need to check if the target address is owned by
a device that doesn't support netpoll or not, simple skipping
will not work.


> 
> But Dave thinks there a bigger problems here, so I recommend first
> figuring out the architecture issues, then we can get back to the policy
> issues.
> 

Ok. Thanks!
