From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 09:47:24 -0700
Message-ID: <469F959C.4090003@candelatech.com>
References: <123837.78916.qm@web56604.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: andrei radulescu-banu <iubica2@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:60569 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760462AbXGSQrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 12:47:37 -0400
In-Reply-To: <123837.78916.qm@web56604.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

andrei radulescu-banu wrote:
>> [Ben] I think a better method would be to allow disabling VLAN HW accel for a NIC with ethtool.
>>     
>
> This requires changes to ethtool and e1000 driver, +other drivers. It is a handy thing to have. I don't view it as a solution to tcpdump - or to the vlan bridging problem. One concern: if we're switching hw accel mode on the fly, we need to carefully protect tx frames that are just about going out and have already been set up for the opposite mode.
>   
I think it would be valid to let a few packets slip through on the old 
behaviour during changeover..or perhaps to drop them
entirely if that is required.

Turning off vlan hw-accel when the nic goes promisc is also going to 
require driver changes, I believe, so
either way you have to do that work.

If tcpdump and/or bridging needs to disable the hw-accel, then it can 
explicitly do so by some API.  That is better than overloading
the promisc flag in my opinion.  This is especially true since promisc 
is not easily readable by user-space and things like tcpdump
cannot have full control of promisc (if a mac-vlan has the NIC in 
promisc mode, for instance, then tcpdump can never disable it.)

> Any comments on what is the expected behavior of 'tcpdump -i eth0.2' vs. 'tcpdump -i eth0'?
>   
I would expect that you see tags with -i eth0, but not with -i eth0.2

That is the way it currently works with non-hw-accell VLANs (or it was 
the last I checked).

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


