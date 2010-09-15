From: Brian Haley <brian.haley@hp.com>
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Wed, 15 Sep 2010 12:01:55 -0400
Message-ID: <4C90EDF3.8010401@hp.com>
References: <87eicvi0cz.fsf@small.ssi.corp> <4C90E11B.7020807@hp.com> <87pqwff2bd.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:43158 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431Ab0IOQB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 12:01:58 -0400
In-Reply-To: <87pqwff2bd.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnaud,

On 09/15/2010 11:34 AM, Arnaud Ebalard wrote:
> Hi Brian,
> 
> Brian Haley <brian.haley@hp.com> writes:
> 
>>> <snip>
>>>
>>> I tested it with 2 different 100M/s switches (Cisco Catalyst 2960 and a
>>> Planex FX08-Mini) so I guess the switch is not the root of the issue. I
>>> came to the conclusion that the link is reported up too soon by the
>>> driver.
>>>
>>> Because the first packets are losts, the result is that address
>>> autoconfiguration is delayed by a few seconds as can be seen on
>>> following capture on the laptop:
>>
>> I've seen similar things on various NICs,
> 
> I remember I add the same kind of issue on a broadcom chip on a dell
> D600 but had no time to investigate at that time. Did you notice the
> problem for different brands? Do you think those are driver-related
> issues or something in common code?

I know I've seen this on an 82571EB (HP NC364T), but I also *thought* I
saw it with bnx2 as well (5708), but I'm not at the moment.  So maybe
this is just hardware or driver-related?  This is what I see:

 [87878.453422] ADDRCONF(NETDEV_UP): eth6: link is not ready
 [87880.298458] e1000e: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
 [87880.299296] ADDRCONF(NETDEV_CHANGE): eth6: link becomes ready
 [87881.369642] e1000e: eth6 NIC Link is Down
 [87883.418475] e1000e: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None

Procurve 5400zl switch, standard settings on the port and NIC.

>> posted a patch last week that unfortunately had other bad
>> side-effects.  When I have time I'll work on it again, but I'd also be
>> curious if there's something that can be done at the driver level to
>> help out, since it seemed like part of the problem is that the link-UP
>> came before the device was actually able to transmit packets, so the
>> DAD was lost.
> 
> I am not familiar with e1000e code but as I said previously I'd be happy
> to test patches to help determine precisely where the packet gets lost
> and why.

I'm not either, the patches I've tried are all for IPv6.

-Brian
