From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] ax25: Stop using magic neighbour cache operations.
Date: Tue, 03 Mar 2015 14:22:41 -0600
Message-ID: <87mw3tzv8u.fsf@x220.int.ebiederm.org>
References: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
	<20150302.164426.494515497595921630.davem@davemloft.net>
	<874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20150303.144509.1694022322984204895.davem@davemloft.net> (David
	Miller's message of "Tue, 03 Mar 2015 14:45:09 -0500 (EST)")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 03 Mar 2015 09:41:47 -0600
>
>> 
>> Before the ax25 stack calls dev_queue_xmit it always calls
>> ax25_type_trans which sets skb->protocol to ETH_P_AX25.
>> 
>> Which means that by looking at the protocol type it is possible to
>> detect IP packets that have not been munged by the ax25 stack in
>> ndo_start_xmit and call a function to munge them.
>> 
>> Rename ax25_neigh_xmit to ax25_ip_xmit and tweak the return type and
>> value to be appropriate for an ndo_start_xmit function.
>> 
>> Update all of the ax25 devices to test the protocol type for ETH_P_IP
>> and return ax25_ip_xmit as the first thing they do.  This preserves
>> the existing semantics of IP packet processing, but the timing will be
>> a little different as the IP packets now pass through the qdisc layer
>> before reaching the ax25 ip packet processing.
>> 
>> Remove the now unnecessary ax25 neighbour table operations.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> Another nice cleanup, applied, thanks Eric.

We can almost universally use the same procedures for generating
link layer headers from neighbour table entries now.  I had hoped
to optimized things by removing function pointers.

The big hold out is DECnet that sets src_mac based on the DECnet source
address.  

Which leads me to the conclusion that since DECnet has a different
algorithm for setting the src_mac than everything else in the kernel
DECnet neighbour table entries can not be used for nexthops for other
protocols :(

DECnet also abuses neigh->output to select by output device which kind
of DECnet header to put on the packets.  But that is easily fixable.

Anyway slowly slowly the neighbour table code becomes more readable
and maintable.

Eric

