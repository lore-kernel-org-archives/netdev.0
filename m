From: Ben Greear <greearb@candelatech.com>
Subject: Re: 2.6.7 tulip performance (with NAPI)
Date: Thu, 07 Oct 2004 11:09:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4165864A.2010805@candelatech.com>
References: <41633174.7070805@candelatech.com>	<16740.17875.574967.11417@robur.slu.se>	<41646587.7070401@candelatech.com>	<41649425.1010102@candelatech.com> <20041006180826.4a092c71.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041006180826.4a092c71.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 06 Oct 2004 17:56:05 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>It may be that other programs would like to use the notify_queue_woken hook, so
>>if this were ever to hit the kernel proper, might want to make this a linked list
>>of callbacks instead of a simple pointer.
> 
> 
> This sort of suggests that pktgen may be better implemented
> via a kind of special queueing discipline.  Just an idea.

Care to elaborate?  From what I can tell, the default code wakes
up the soft-irq thread when the NIC queue has available space again.  I
suppose that that will in turn wake up the sockets waiting to write
to that NIC again.  To me, it seemed more efficient, if perhaps less
flexible, to have the queue-has-space callback to directly wake the
writer thread(s).

I do wonder how this would work with virtual interfaces, such as 802.1Q
vlans, which have no queues.  I could make the pktgen hook aware of the
VLAN <-> ethX relationship, or could have the callback generate callbacks for
all associated VLANs, but neither seems very elegant or scalable.

How does the existing (non pktgen) architecture work for VLAN devices
and stopping/starting the queues in the underlying devices?

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
