From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Mon, 21 May 2012 05:56:23 +0200
Message-ID: <1337572583.3361.8.camel@edumazet-glaptop>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, davem@davemloft.net
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59483 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749Ab2EUD42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2012 23:56:28 -0400
Received: by weyu7 with SMTP id u7so2913984wey.19
        for <netdev@vger.kernel.org>; Sun, 20 May 2012 20:56:27 -0700 (PDT)
In-Reply-To: <ef780bd0e0b9b9e60e37fa74101f0f66@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-05-20 at 22:18 +0300, Denys Fedoryshchenko wrote:
> On 2012-05-20 22:07, Eric Dumazet wrote:
> >
> > You could try latencytop, I am not sure if some obvious things will
> > popup.
> For sure i did. Nothing unusual here, max 5ms latency
> Cause                                                Maximum     
> Percentage
> [__skb_recv_datagram]                               4.1 msec   

Interesting

So your workload is a mix of pings, and receive.

Problem is softirq handler might use a lot of time to complete the
receives, because of TCP stack complexity. And BQL use softirq to
restart the transmits on the same cpu.

tcp_data_queue() can copy the received data directly to user space.
(taking page faults...)

Could you check if net-next behaves the same ?
