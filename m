From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ax25: Stop using magic neighbour cache
 operations.
Date: Tue, 03 Mar 2015 14:45:09 -0500 (EST)
Message-ID: <20150303.144509.1694022322984204895.davem@davemloft.net>
References: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
	<20150302.164426.494515497595921630.davem@davemloft.net>
	<874mq22imc.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	linux-hams@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 03 Mar 2015 09:41:47 -0600

> 
> Before the ax25 stack calls dev_queue_xmit it always calls
> ax25_type_trans which sets skb->protocol to ETH_P_AX25.
> 
> Which means that by looking at the protocol type it is possible to
> detect IP packets that have not been munged by the ax25 stack in
> ndo_start_xmit and call a function to munge them.
> 
> Rename ax25_neigh_xmit to ax25_ip_xmit and tweak the return type and
> value to be appropriate for an ndo_start_xmit function.
> 
> Update all of the ax25 devices to test the protocol type for ETH_P_IP
> and return ax25_ip_xmit as the first thing they do.  This preserves
> the existing semantics of IP packet processing, but the timing will be
> a little different as the IP packets now pass through the qdisc layer
> before reaching the ax25 ip packet processing.
> 
> Remove the now unnecessary ax25 neighbour table operations.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Another nice cleanup, applied, thanks Eric.
