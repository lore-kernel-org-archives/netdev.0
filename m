From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [RFC] IPSEC failover and replay detection sequence numbers
Date: Fri, 29 Oct 2004 18:15:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41826CB3.2080306@balabit.hu>
References: <1099045435.2888.47.camel@nienna.balabit>	 <1099054721.1027.118.camel@jzny.localdomain>	 <1099056277.2888.71.camel@nienna.balabit> <1099062095.1023.14.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ipsec-tools-devel@lists.sourceforge.net,
        vpn-failover@lists.balabit.hu
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099062095.1023.14.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


   Hi,

jamal wrote:
> ok. It should still get better in a short period of time though.
> Moral in my point is i hope you make it an optional feature.

   Definitely.

>>  To play with numbers: say that you have 5K users, so let's suppose
>>there are at most 20K IPSEC SAs. If you decide to send an update per
>>second, that would mean 20K updates/second. If each update message is 20
>>bytes long, that means that on Ethernet you can transmit all of them in
>>about 280 packets. 
> 
> Are you batching? 

   Of course! I think it is a must, especially if we use such tiny 
messages. But this is dependant on the user-space code of course.

> In my count: Assuming 20bytes is in a packet of its own - your numbers
> translate to 20Kpps which is > 10Mbps ;-> 
> I suppose SAs will be much lower rate. So you need probably a dedicated
> 100Mbps just for the syncing. I would also say SA updates should be
> prioritized over replay messages.

   I think a dedicated 100mbps/1Gbps interface is not a problem anyway...

>>That's not too much. (I suppose the 20K pfkey
>>messages would be much more of a problem, though...)
> 
> Why not use the netlink events (you mention pfkey).
> 
> Batching them with a timeout should help.

   Agreed. However, for the initial tests I chose pfkey because racoon 
uses pfkey only, so it would be good enough for me as a prototype. I 
think it would not be too much work to implement the netlink interface 
as well - with batching included.

-- 
  Regards,
   Krisztian KOVACS
