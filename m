From: Ben Greear <greearb@candelatech.com>
Subject: Re: "Loopback" route through two cards?
Date: Thu, 12 Sep 2002 22:44:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D817B2E.7020207@candelatech.com>
References: <200209031254.QAA02008@sex.inr.ac.ru> <3D81709E.7040506@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> kuznet@ms2.inr.ac.ru wrote:

>> 2. You cannot receive packets with local address from any device
>>    but loopback.
>>
>>    This is impossible, but wthis time without not editing kernel,
>>    removing the check for local addresses in fib_validate_source().
> 
> 
> Any clues to which part of this method needs to be changed?  I see nothing
> obviously about checking for local IPs, but I'm sure it's in there 
> somewhere!

So, after adding printk's everywhere, I see that this seems to be the
check that fails:

	if (res.type != RTN_UNICAST) {
            printk("fib_frontend:  was not UNICAST: %x\n", res.type);
            //goto e_inval_res;
         }


After commenting that out, I can send pkts in one direction, but in the other
direction, the ARP is not ever answered (I see it sent with ethereal).
It appears that the only reason it
goes in one direction is that I got lucky and the arp table had the entry for
some reason.

So, I have to figure out how to make ARP work in this case, and I think it
will all start working!


Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
