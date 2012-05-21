From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire X4150(x86)
 and e1000e
Date: Mon, 21 May 2012 11:06:16 +0300
Message-ID: <6d7500e1c3b4b191c0b5a11003b161d6@visp.net.lb>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
 <88c43001441945e1431609db252b69e7@visp.net.lb>
 <df211722d18136698aeeda2f17b876e2@visp.net.lb>
 <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
 <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
 <79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
 <CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
 <4775d023592b876909aceb152f94aa01@visp.net.lb>
 <1337540825.3361.0.camel@edumazet-glaptop>
 <ef780bd0e0b9b9e60e37fa74101f0f66@visp.net.lb>
 <1337572583.3361.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>, <jeffrey.t.kirsher@intel.com>,
	<jesse.brandeburg@intel.com>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:33065 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab2EUIG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 04:06:29 -0400
In-Reply-To: <1337572583.3361.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-05-21 06:56, Eric Dumazet wrote:
> On Sun, 2012-05-20 at 22:18 +0300, Denys Fedoryshchenko wrote:
>> On 2012-05-20 22:07, Eric Dumazet wrote:
>> >
>> > You could try latencytop, I am not sure if some obvious things 
>> will
>> > popup.
>> For sure i did. Nothing unusual here, max 5ms latency
>> Cause                                                Maximum
>> Percentage
>> [__skb_recv_datagram]                               4.1 msec
>
> Interesting
>
> So your workload is a mix of pings, and receive.
>
> Problem is softirq handler might use a lot of time to complete the
> receives, because of TCP stack complexity. And BQL use softirq to
> restart the transmits on the same cpu.
>
> tcp_data_queue() can copy the received data directly to user space.
> (taking page faults...)
>
> Could you check if net-next behaves the same ?
Not sure it is a lot of time, after all it is 2 x core quad machine, 
should be enough fast for pings.
It will cause stalls on small packets even more seems.

Tested latest git, net-next, still the same, stalls.
hardware latency detector are silent by the way, so there is no 
significant SMI.


---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
