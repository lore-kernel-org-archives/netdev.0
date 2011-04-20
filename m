From: Alexander Hoogerhuis <alexh@boxed.no>
Subject: Re: A patch you wrote some time ago (aka: "[patch 41/54] ICMP: Fix
 icmp_errors_use_inbound_ifaddr sysctl")
Date: Wed, 20 Apr 2011 10:38:51 +0200
Message-ID: <4DAE9B9B.90509@boxed.no>
References: <20110419165411.GO9569@sequoia.sous-sol.org> <4DAE9824.10802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@sous-sol.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DAE9824.10802@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20.04.2011 10:24, Patrick McHardy wrote:
>
> That might be a possibility to fix this for your case. But I'm
> wondering why you're turning this on at all and not have routing
> decide the correct source address?

Not a whole lot of tuning, but trying to figure why this would not work 
as any other VRRP implementation would work on other routers/OSes.

My case seems to be a general problem for ICMP errors, as the IP stack 
tends to want to listen more to advice coming back with the source IP of 
the gateway, not a third party.

If you have two machines (A and B) run VRRP and share an IP (C), then 
any ICMP redirect should have the VRRP IP as source (C), and the way it 
works today (with or without sysctl_icmp_errors_use_inbound_ifaddr) is 
that it will have the source set to the primary IP of the source interface.

I suspect this holds for any other ICMP message sent back to hosts in 
the connected network as well, such as PMTU-related issues, etc.

In my case nodes in the connected subnet would get ICMP redirects from 
the primary IPs, and thus not listen to them as they are arriving from 
nodes not listen in the list of known gateways.

It would make more sense when returning ICMP messages the source IP 
would be the actual IP it is recveied on, not the primary IP of the 
interface.

mvh,
A
-- 
Alexander Hoogerhuis | http://no.linkedin.com/in/alexh
Boxed Solutions AS   | +47 908 21 485 - alexh@boxed.no
"Given enough eyeballs, all bugs are shallow." -Eric S. Raymond
