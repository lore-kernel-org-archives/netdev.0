From: Ben Greear <greearb@candelatech.com>
Subject: Re: Pktgen receive hook in dev.c?
Date: Fri, 29 Apr 2005 17:28:35 -0700
Message-ID: <4272D133.4040201@candelatech.com>
References: <4272C384.50901@candelatech.com> <1114820059.8929.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1114820059.8929.17.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2005-29-04 at 16:30 -0700, Ben Greear wrote:
> 
>>I am curious if there is any interest in adding a hook in the netif_receive_skb
>>method to allow receiving (and consuming) pktgen packets.  This gives the ability
>>to get some good packet receive & latency stats using pktgen.
>>
>>I asked this a year or so ago and was told no, but since then the netpoll and
>>TC_NCLS hooks have been added.... so maybe hooks are OK again?
>>
> 
> 
> Write an action. It should be trivial to consume pktgen. Infact if all
> you wanted was to count, use the gact action.

I want a lot more than count, including timestamp, sequence number, etc.

In order to know it's a pktgen packet, I check for a magic value at the beginning
of the UDP header.  Since this could potentially collide with some 'real' packet,
I also check a flag to see if the net_device has a particular flag set indicating
it is actively accepting pktgen packets...

I assume this means I'd need a custom match function in the kernel.  Is there
an example of how to do something like this using your framework?

Thanks,
Ben

> 
> cheers,
> jamal
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
