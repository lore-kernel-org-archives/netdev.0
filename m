From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] via-velocity: Give RX descriptors to the NIC later on
 open or MTU change
Date: Mon, 28 Dec 2009 10:27:25 +0100
Message-ID: <4B3879FD.60102@computer.org>
References: <1260842710.4532.691.camel@localhost> <20091225.182102.112589642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	508527@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay003.isp.belgacom.be ([195.238.6.53]:26607 "EHLO
	mailrelay003.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750858AbZL1J3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 04:29:24 -0500
In-Reply-To: <20091225.182102.112589642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>> velocity_open() calls velocity_give_many_rx_descs(), which gives RX
>> descriptors to the NIC, before installing an interrupt handler or
>> calling velocity_init_registers().  I think this is very unsafe and it
>> appears to explain the bug report <http://bugs.debian.org/508527>.
>>
>> On MTU change, velocity_give_many_rx_descs() is again called before
>> velocity_init_registers().  I'm not sure whether this is unsafe but
>> it does look wrong.
>>
>> Therefore, move the calls to velocity_give_many_rx_descs() after
>> request_irq() and velocity_init_registers().
>>
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>> ---
>> This is untested; I don't have this hardware.
> 
> Although this patch looks fine to me, I don't want to apply
> it until someone tests it.

I have successfully booted a 2.6.32.2 kernel with this patch applied on top on a PXE-booting machine with nfsroot. If you consider that to be a sufficient test then please feel free to add my

Tested-by: Jan Ceuleers <jan.ceuleers@computer.org>

Otherwise, please let me know which other tests you would like me to carry out.

Note though that I am unable to reproduce the original bug on my system.

Cheers, Jan
