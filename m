From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: Thu, 31 Mar 2005 13:24:40 -0800
Message-ID: <424C6A98.1070509@hp.com>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>	<20050331120410.7effa94d@dxpl.pdx.osdl.net> <1112303431.1073.67.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
In-Reply-To: <1112303431.1073.67.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The repurcassions of going from per-CPU-for-all-devices queue
> (introduced by softnet) to per-device-for-all-CPUs maybe huge in my
> opinion especially in SMP. A closer view of whats there now maybe
> per-device-per-CPU backlog queue.
> I think performance will be impacted in all devices. imo, whatever needs
> to go in needs to have some experimental data to back it

Indeed.

At the risk of again chewing on my toes (yum), if multiple CPUs are pulling 
packets from the per-device queue there will be packet reordering.  HP-UX 10.0 
did just that and it was quite nasty even at low CPU counts (<=4).  It was 
changed by HP-UX 10.20 (ca 1995) to per-CPU queues with queue selection computed 
from packet headers (hash the IP and TCP/UDP header to pick a CPU) It was called 
IPS for Inbound Packet Scheduling.  11.0 (ca 1998) later changed that to "find 
where the connection last ran and queue to that CPU" That was called TOPS - 
Thread Optimized Packet Scheduling.

fwiw,

rick jones
