From: Ben Greear <greearb@candelatech.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 13:40:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F60DDCC.5020906@candelatech.com>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>	<3F60CA6D.9090503@pobox.com>	<3F60D0F3.8080006@candelatech.com> <20030911131219.0ab8dfdd.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030911131219.0ab8dfdd.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Generic networking device queues drop when the overflow.
> 
> Whatever dev->tx_queue_len is set to, the device driver needs
> to be prepared to be able to queue successfully.
> 
> Most people run into problems when they run stupid UDP applications
> that send a stream of tinygrams (<~64 bytes).  The solutions are to
> either fix the UDP app or restrict it's socket send buffer size.

Is this close to how it works?

So, assume we configure a 10MB socket send queue on our UDP socket...

Select says its writable up to at least 5MB.

We write 5MB of 64byte packets "righ now".

Did we just drop a large number of packets?

I would expect that the packets, up to 10MB, are buffered in some
list/fifo in the socket code, and that as the underlying device queue
empties itself, the socket will feed it more packets.

The device queue, in turn, is emptied as the driver is able to fill it's
TxDescriptors, and the hardware empties the TxDescriptors.

Obviously, I'm confused somewhere....

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
