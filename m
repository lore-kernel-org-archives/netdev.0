From: Massimo Cetra <mcetra@navynet.it>
Subject: Re: Bridged networking panics
Date: Wed, 04 Jul 2012 15:50:44 +0200
Message-ID: <4FF44A34.4030901@navynet.it>
References: <4FEC62DD.6000303@navynet.it>  <4FF41E1A.4070102@navynet.it> <1341408298.2583.1963.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Massimo Cetra <ctrix+debianbugs@navynet.it>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341408298.2583.1963.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/07/2012 15:24, Eric Dumazet wrote:

> Posting a bug report is not enough to get people working for free on the
> problem.

Thanks for the reply.

I'd like to point out that without a reply of what is need of what i'm 
doing wrong i cannot provide anything useful.

> Apparently your configuration is kind of special if nobody but you hits
> the problem so often.

> So it would help if you can reproduce the bug using current kernel and
> provide all necessary steps to reproduce the bug. Ideally a script.sh
> file doing all the configuration you use to trigger the bug, assuming
> a basic machine freshly booted with no special config already done.

I can try to setup a fresh KVM image and see if the bug is reproduceable 
there. Would it be ok ?

> The panics dont happen in the bridge code itself, but in the
> BRIDGE_NETFILTER one. Do you need it, and why ?
>
> Are you using vlans ?

No, no VLANS.

I have 2 real network cards (Broadcom Corporation NetXtreme II BCM5716) 
configured as bridges.

Each bridge (br0 and br1) has an ip address which is fixed (does never 
change).

The server(s) run KVM machines which are attached to tun interfaces 
(created with "vde_tunctl -u $user -t $IFACE)

Each virtual KVM server has an IP address that is forwarded through the 
bridge and has as gateway the router of the main server.

Up to this point there is nothing strange in the configuration and if 
the system is used this way, there are no panics.


The (maybe) peculiar configs are:

1) heartbeat is installed and creates alias interfaces for the bridge 
and assigns them an IP address. So the server has br0:1 and br1:1 that 
are associated with a couple of IP addresses.

2) the server runs ipvs (to redirect HTTP requests to two KVM servers 
that are natted behind the br0:1 br1:1 addresses).


IF i remove the br0:1 and br1:1 interfaces (that are configured with the 
ip addresses used by IPVS i don't have any single problem and the crash 
(at least with 3.2.21) doesn't happen.

So, if i turn off heartbeat (and the alias ip addresses used by IPVSare 
switched to the other host) there are no panics.

The more the traffic, the quicker the panic happens.

Note that up to 2.6.36 this configuration was working without problems.

Ah, the last setting that i modified is disabling tcp_sack in sysctl.conf.

> Please try following patch

I will try on the latest 3.2.y for now, trying to replicate the problem.

Thanks again,

MC
