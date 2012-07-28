From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: more interrupts (lower performance) in bare-metal compared
 with running VM
Date: Sat, 28 Jul 2012 06:32:45 +0200
Message-ID: <1343449965.2626.13121.camel@edumazet-glaptop>
References: <CAB7xdi=DrE356=U1Jr1Z=ROo2X3XNM5uKcgiZJTKY+EdsTu7gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: sheng qiu <herbert1984106@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CAB7xdi=DrE356=U1Jr1Z=ROo2X3XNM5uKcgiZJTKY+EdsTu7gw@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-07-27 at 22:09 -0500, sheng qiu wrote:
> Hi all,
> 
> i am comparing network throughput performance under bare-metal case
> with that running VM with assigned-device (assigned NIC). i have two
> physical machines (each has a 10Gbit NIC), one is used as remote
> server (run netserver) and the other is used as the target tested one
> (run netperf with different send message size, TCP_STREAM test). the
> remote NIC is connected directly with the tested NIC, both are 10Gbit.
> fore bare-metal case, i enable 1 cpu core, for VM i also configure 1
> vcpu (the memory is sufficient for both bare-metal and VM case).  i
> run netperf for 120 seconds and got the following results:
> 
>                        send message    interrupts   throughput (mbit/s)
> bare-metal             256               10696290            1114.84
>                             512               10106786            1391.92
>                             1024              10071032           1508.09
>                             2048              4560857             3434.65
>                             4096              3292200             4762.26
>                             8192              3169801             4733.89
>                             16384            2780529              4892.6
> 

Are these interrupt counts taken on the receiver ?

> VM(assigned NIC)   256               3817904              2249.35
>                              512               3599007              4342.81
>                             1024              3005601              4134.69
>                              2048             2952122              4484
>                              4096             2682874              4566.34
>                              8192             2786719              4734.39
>                              16384           2603835              4540.47
> 
> as shown, the interrupts for bare-metal case is much more than the VM
> case for some message size. we also see the throughput for those
> situations is lower than VM case. it's strange that the bare-metal has
> lower performance than the VM case. Does anyone have comments on this?
> i am very confused.

Well, I think you answered to your question. High interrupt rates
are not good for throughput. They might be good for latencies.

Using a VM adds delays and several frames might be delivered per
interrupt.

Using bare metal is faster and only one frame is delivered by NIC per
interrupt.

Try TCP_RR instead of TCP_STREAM for example.

What NIC is it exactly ? It seems it has no coalescing or LRO strategy.

ethtool -k eth0
ethtool -c eth0

What kernel version as used, because 4892 Mbits is not line rate.


