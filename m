From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] PKT_SCHED: dsmark must take care of shared/cloned skbs
Date: Mon, 20 Dec 2004 09:06:06 +0100
Message-ID: <41C687EE.1090205@trash.net>
References: <20041218170017.GH17998@postel.suug.ch> <1103487827.1048.188.camel@jzny.localdomain> <20041219203641.GL17998@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041219203641.GL17998@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * jamal <1103487827.1048.188.camel@jzny.localdomain> 2004-12-19 15:23
> 
>>If the qdisc at that level muddies the packet thats fair game - thats
>>what goes out on the wire. So we should leave the code as is.
> 
> 
> Agreed for egress but I think it is needed for stuff like IMQ. It's
> debatable whether we should take care of IMQ and alike though.
> 

You shouldn't care about IMQ, but we still need to copy the packet
before modifying it if the data is shared. Otherwise we have a race
on SMP with AF_PACKET sockets, depending on when the packet is read
it can be either modified or not.

Converting dsmark to an action sounds like the best long-term solution.

Regards
Patrick
