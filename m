From: Mark Huth <mhuth@mvista.com>
Subject: Re: [Bonding-devel] quick help with bonding?
Date: Thu, 29 Mar 2007 16:01:18 -0700
Message-ID: <460C453E.80208@mvista.com>
References: <460BE5F0.7070606@nortel.com> <20070329181617.GA25770@gospo.rdu.redhat.com> <460C38EF.1080509@nortel.com> <4074.1175207458@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <cfriesen@nortel.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:64078 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945896AbXC2XBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 19:01:21 -0400
In-Reply-To: <4074.1175207458@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Jay Vosburgh wrote:
> Chris Friesen <cfriesen@nortel.com> wrote:
> [...]
>   
>> I have a ppc64 blade running a customized 2.6.10.  At init time, two of
>> our gigE links (eth4 and eth5) are bonded together to form bond0.  This
>> link has an MTU of 9000, and uses arp monitoring.  We're using an ethernet
>> driver with a modified RX path for jumbo frames[1].  With the stock
>> driver, it seems to work fine.
>>     
>
> 	2.6.10 is pretty old, and there have been a number of fixes to
> the bonding ARP monitor since then, so it may be that it is simply
> misbehaving (presuming that you're running the 2.6.10 bonding driver).
> Are you in a position to test against a more recent kernel (and/or
> bonding driver)?  Does the miimon misbehave in a similar fashion?
>
>   
>> The problem is that eth5 seems to be bouncing up and down every 15 sec or
>> so (see the attached log excerpt).  Also, "ifconfig" shows that only 3
>> packets totalling 250 bytes have gone out eth5, when I know that the arp
>> monitoring code from the bond layer is sending 10 arps/sec out the link.
>>     
> [...]
>   
>> Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: scheduling interface eth4 to be reset in 30000 msec.
>>     
> [...]
>   
>> Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: cancelled scheduled reset of interface eth5
>>     
>
> 	These two messages (which appear a number of times in your log
> excerpt) are not from the standard mainline bonding driver, even in
> 2.6.10.  I don't know what this is all about.
>
>   
>> If I boot the system and then log in and manually create the bond link
>> (rather than it happening at init time) then I don't see the problem.
>>     
>
> 	I would hazard to guess that it's an ARP monitor problem; older
> versions of the ARP monitor had less than intelligent means to figure
> out what the bond's IP address is (to use for the probes).  This, along
> with some logic problems in the monitor code itself, led to various
> problems with the ARP probes and the sort of "up / down" cycle of
> behavior you seem to be seeing.
>
> 	-J
>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> -
>   
I'll second what Jay said.  I support a version of the 2.6.10 kernel 
with bonding, and I needed to upgrade the bonding that was native to 
2.6.10 to get reasonable behavior.  You may also need a newer ifenslave.

It also looks like the mii interface is not well-behaved, because of the 
initialization messages related to link speed.
