From: Ben Greear <greearb@candelatech.com>
Subject: Re: 2.4.21: bug report for tg3:  tx lockup when changing MTU
Date: Fri, 01 Aug 2003 17:24:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2B04A0.9030101@candelatech.com>
References: <3F2AEFBF.3040604@candelatech.com> <3F2AFE7A.10203@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F2AFE7A.10203@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Ben Greear wrote:
> 
>> I just noticed that if you change the MTU of a tg3 NIC, it will not work
>> untill you ifdown/ifup it.  This problem is repeatable on tg3, and 
>> does not
>> happen with the e1000 driver/cards.
>>
>> I am setting the MTU via an ioctl call, not via ifconfig or something 
>> like
>> that.
> 
> 
> 
> Can you provide the ioctl call info, so I can reproduce?
> 
> And, are you changing MTU when the interface is up or down?

Interface is up and transmitting/receiving pkts at the time.

I just reproduced it with commands below.  It is probably a race,
so not sure that either of these will always fail.  Running about
10kpps rx+tx.  Was sending pktgen (UDP) traffic of fixed length, so the actual
transmitted packet sizes remains the same in this case.

# MTU is at 1500
ifconfig eth5 mtu 4096  #worked
ifconfig eth5 mtu 4000  # failed.





-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
