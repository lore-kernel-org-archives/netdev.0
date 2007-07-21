From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linux, tcpdump and vlan
Date: Sat, 21 Jul 2007 10:57:14 -0700
Message-ID: <46A248FA.1050403@candelatech.com>
References: <997818.30021.qm@web56615.mail.re3.yahoo.com>	<m31wf226fw.fsf@maximus.localdomain>	<46A11C54.2090100@candelatech.com> <m3sl7idmb4.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrei radulescu-banu <iubica2@yahoo.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:45312 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164AbXGUR5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 13:57:24 -0400
In-Reply-To: <m3sl7idmb4.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> Ben Greear <greearb@candelatech.com> writes:
>
>   
>> There is already a flag you can set on vlan devices (reorder-header)
>> that strips the VLAN tag before presenting it to user-space.
>>     
>
> Sure, but isn't it only valid for VLAN device (not the main ethX)?
> I.e., can you have the tag stripped from frames captured on ethX?
>   
No.  I don't see a good reason to strip on ethX.  That hardware accel 
VLANs strip
is an inconvenience in my opinion, no need to force it in software as well.
>> On tx, if it shows up on the vlan device, we add that device's VID to
>> the header if no VID is currently in the SKB.  If it is in the SKB header
>> we change the VID to be the tx dev's VID (if it was different).  This allows user-space
>> to send a raw ethernet frame on a vlan device and have it automatically
>> go out of the box on the correct vlan.  User-space can also send raw VLAN frames
>> and have those also go out on the correct VLAN.
>>     
>
> Well... I think the tag should be added unconditionally (for things like
> QinQ) but that's trivial and minor.
>   
I think that for Q in Q, we would need some explicit flag on each skb to 
know when to add or modify
the VID.  I was never able to think of an automatic solution that worked 
in all cases
(bridging, writing raw packets from user space, normal receive, normal 
transmit, ...)

Modifying the bridging code would fix that path, and adding a socket opt 
to deal with writing
raw packets from user-space should handle the other tricky case I believe.

> IOW: I think all Ethernet interfaces should always be VLAN-aware,
> stripping the tag (only one) early on RX and adding it late on TX.
> That means tcpdump would see packets with exactly one tag removed
> (unless there was no tag), in both RX and TX.
>
> Tcpdump would need other means to get VLAN id...
>   
What benefit will this add?  It will certainly decrease performance to 
copy around
the header for every VLAN packet, so there would have to be a good reason to
add this logic...

Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


