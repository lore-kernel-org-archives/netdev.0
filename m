From: Brian Haley <brian.haley@hp.com>
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Wed, 15 Sep 2010 11:07:07 -0400
Message-ID: <4C90E11B.7020807@hp.com>
References: <87eicvi0cz.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:44743 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079Ab0IOPHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 11:07:11 -0400
In-Reply-To: <87eicvi0cz.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2010 09:48 AM, Arnaud Ebalard wrote:
> Hi,
> 
> I have a Dell E4300 Laptop running 2.6.35.4. It contains an Intel
> 82567LM-3 Gigabit chipset. Here is what lspci reports:
> 
<snip>
> 
> When connecting the laptop to an ethernet switch, the driver performs
> autoneg and then reports the link up via Netlink. This is monitored by
> both netplug and UMIP to emit a DHCP request and an IPv6 Router
> Solicitation (respectively) as soon as the link is reported UP and
> RUNNING.
> 
> Most of the time, those first packets never reach the switch, i.e. the
> packets are visible locally via tcpdump but are not seen on the remote
> side.
> 
> I tested it with 2 different 100M/s switches (Cisco Catalyst 2960 and a
> Planex FX08-Mini) so I guess the switch is not the root of the issue. I
> came to the conclusion that the link is reported up too soon by the
> driver.
> 
> Because the first packets are losts, the result is that address
> autoconfiguration is delayed by a few seconds as can be seen on
> following capture on the laptop:

I've seen similar things on various NICs, posted a patch last week that
unfortunately had other bad side-effects.  When I have time I'll work on
it again, but I'd also be curious if there's something that can be done
at the driver level to help out, since it seemed like part of the problem
is that the link-UP came before the device was actually able to transmit
packets, so the DAD was lost.

-Brian
