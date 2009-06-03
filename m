From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Question regarding protocol specific mtu for FCoE
Date: Wed, 03 Jun 2009 15:36:49 -0700
Message-ID: <4A26FB01.1020502@hp.com>
References: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>	<4A26BAF7.3070301@hp.com>	<7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>	<4A26E4AE.4020607@hp.com> <adazlcp814o.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Zou\, Yi" <yi.zou@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Leech\, Christopher" <christopher.leech@intel.com>,
	"Dev\, Vasu" <vasu.dev@intel.com>,
	"Love\, Robert W" <robert.w.love@intel.com>,
	"Ma\, Steve" <steve.ma@intel.com>,
	"Waskiewicz Jr\, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher\, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:1083 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756116AbZFCWgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 18:36:50 -0400
In-Reply-To: <adazlcp814o.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
>  > So FCoE cannot say "fcoe_mtu = min(OPTIMAL_FCOEMTU,netdev->mtu)" and
>  > send-down frames based on that?
> 
> I think the point is that FCoE wants to use OPTIMAL_FCOEMTU (2KB + a bit
> for headers) even when netdev->mtu is 1500.  (eg datacenter network
> supports baby jumbo frames so FCoE traffic that stays within the network
> should use OPTIMAL_FCOEMTU, while lots of IP traffic is going out onto a
> 1500-byte MTU campus and having TCP doing lots of PMTU discovery is a
> pain)

Aren't all stations in the same broadcast domain "supposed" to have the same MTU, 
at least down at L2? So, a station in the broadcast domain just doing IP and a 
station in the broadcast domain doing IP+FCoE "should" have the same MTU at the 
HW level right?

I could see where there would be lots of PMTU going-on if the communications were 
to off-campus sites also had an FCoE upping their MTU.  Otherwise, the MSS 
exchange at connection establishment is going to preclude it right?  PMTU only 
"hits" when one has a so called "dumb-bell" network which is "wider" at the ends 
than in the middle.
