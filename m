From: Ben Greear <greearb@candelatech.com>
Subject: Re: 8169 driver with NetGear GA511 card.
Date: Thu, 28 Oct 2004 10:47:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <418130C4.3010207@candelatech.com>
References: <41802CA8.8070900@candelatech.com> <20041028074827.GA3572@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041028074827.GA3572@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:

> The r8169 in -mm and in -netdev includes some extra buzzword-compliant
> features (TX csum/SG and TSO mainly). The changes are isolated in a
> single patch against 2.6.9 available at:
> http://www.fr.zoreil.com/people/francois/misc/20041020-2.6.9-r8169.c-test.patch
> 
> I will not claim it is as stable as vanilla 2.6.9 should be.

I'm running tests at the ethernet frame (skb) level, so I would not
expect the IP offload to help much.

Do you have any performance numbers for your 8169 cards for me to
compare against?

> Please send the usuals 'lspci -vx' + /proc/interrupts contents during
> activity + complete dmesg + short description of the generated traffic.
> I will hardly dissect it before the week end but there is a problem. :o(

I'll get this in a bit, as I have locked up the keyboard again.  This time,
I was still using the non-NAPI code which had run over-night at around 5Mbps...

I tried a different network setup, and noticed that the 8169 was only
negotiating 10bt/HD.  That would explain the poor performance numbers.
The NIC was connected to a BCM5705M when I noticed this, though it had
been connected to an e1000 earlier.

I tried forcing both NICs to 100bt/FD.  The BCM would force to that speed,
but the 8169 would only force to 100bt/HD.  While attempting to change them
back to auto-negotiate, I noticed that the keyboard had quit working...

With regard to the BCM, it is interesting in that ethtool reports that it
supports only up to 100bt/FD, but it advertises 1000bt/FD.

The wierd advertise and negotiation stuff could be at least partly my
fault as I have a program that manipulates these settings from default.
I will continue to play with this later this evening...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
