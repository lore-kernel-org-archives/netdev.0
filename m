From: Ben Greear <greearb@candelatech.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 14:29:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F60E947.4090005@candelatech.com>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>	<3F60CA6D.9090503@pobox.com>	<3F60D0F3.8080006@candelatech.com>	<20030911131219.0ab8dfdd.davem@redhat.com>	<3F60DDCC.5020906@candelatech.com> <20030911140746.4f0384a1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030911140746.4f0384a1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 11 Sep 2003 13:40:44 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>So, assume we configure a 10MB socket send queue on our UDP socket...
>>
>>Select says its writable up to at least 5MB.
>>
>>We write 5MB of 64byte packets "righ now".
>>
>>Did we just drop a large number of packets?
> 
> 
> Yes, we did _iff_ dev->tx_queue_len is less than or equal
> to (5MB / (64 + sizeof(udp_id_headers))).

Thanks for that clarification.  Is there no way to tell
at 'sendto' time that the buffers are over-full, and either
block or return -EBUSY or something like that?

Perhaps the poll logic should also take the underlying buffer
into account and not show the socket as writable in this case?

Supposing in the above example, I set tx_queue_len to
(5MB / (64 + sizeof(udp_id_headers))), will
the packets now be dropped in the driver instead, or will there
be no more (local) drops?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
