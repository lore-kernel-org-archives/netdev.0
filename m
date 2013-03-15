From: Thomas Martitz <thomas.martitz@hhi.fraunhofer.de>
Subject: Re: Trying to implement secondary loopback
Date: Fri, 15 Mar 2013 14:49:51 +0100
Message-ID: <514326FF.6020205@hhi.fraunhofer.de>
References: <513F1A17.1000809@hhi.fraunhofer.de> <CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com> <3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de> <87r4jjav00.fsf@xmission.com> <3D7E565A361FB844A410A5EFCDD7BA4002EF11@MXSRV3.fe.hhi.de> <878v5r9es7.fsf@xmission.com> <5142CE23.9070804@hhi.fraunhofer.de> <87ip4t598t.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:37970 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401Ab3CONtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 09:49:47 -0400
In-Reply-To: <87ip4t598t.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 15.03.2013 09:59, schrieb Eric W. Biederman:
>>
>>
>> I have trouble understanding this approach. Does it mean that I have
>> to expose two interfaces from my kernel module. I.e. call
>> register_netdev() twice?
>
> The suggestion was to have one driver, driving two identical nics
> plugged into the same machine with a cable between them. That creates no
> special cases on your side for testing.


The NIC doesn't exist yet, I'm developing it along with the driver (both 
part of my Master thesis). I'm implementing it in VHDL for an FPGA that 
is on a PCIe card, and I can only use one card.

During development of the NIC I want to approach from the kernel module 
level over to PCIe, MAC hardware and finally PHY level. For each of 
these I want to establish a loopback mechanism for testing and 
verification as I progress (and loopback because the level below doesn't 
exist yet).

>
> Shrug.  It is your driver, and your hardware, feel free to
> develop however you want.
>
>> Or use a "struct pernet_operations" to create
>> a netdev on a per-namespace basis.
>> If I do either of the above I end up with two "struct netdev" and two
>> MAC addresses, which I don't really want. Also I would need to
>> transfer from one netdev to the other in the driver's ndo_start_xmit()
>> method instead of simply calling netif_rx().
>>
>> Perhaps I'm misunderstanding, I'm s
>>
>> During my development, looping back the data in ndo_start_xmit() is
>> only a first step. The next step is to pass the data via PCIe and
>> getting the same data back later. This is why I want to keep the
>> loopback as simple/straightforward as possible.
>
> I guess the question is why do you want to loopback the data?
>
> For testing your NIC driver?  Or are you trying some strange scheme
> where you try and offload processing between sockets on the same machine?
>


I want the loopback during development of the NIC hardware. Once the NIC 
is done I drop the loopback and the card will be used for real networking.
Thus, I want the loopback to a) test my driver, and b) test the hardware 
(for each milestone) as I'm implementing it.

Best regards.

-----
visit us at

OFC 2013 / March 19-21 / Anaheim Convention Center, CA, USA / booth 11807

NABSHOW 2013 / April 8-11 / Las Vegas Convention Center, Nevada, USA / booth C7843

www.hhi.fraunhofer.de/events
