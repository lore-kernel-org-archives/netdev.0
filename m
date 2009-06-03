From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: Question regarding protocol specific mtu for FCoE
Date: Wed, 3 Jun 2009 16:00:00 -0700
Message-ID: <7C88852EF6F99F4EB538472FCFEBE2223A7E7114@orsmsx509.amr.corp.intel.com>
References: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>
	<4A26BAF7.3070301@hp.com>
	<7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>
	<4A26E4AE.4020607@hp.com> <adazlcp814o.fsf@cisco.com>
 <4A26FB01.1020502@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Dev, Vasu" <vasu.dev@intel.com>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"Ma, Steve" <steve.ma@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Rick Jones <rick.jones2@hp.com>, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7789 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579AbZFCXAA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 19:00:00 -0400
In-Reply-To: <4A26FB01.1020502@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Roland Dreier wrote:
>>  > So FCoE cannot say "fcoe_mtu = min(OPTIMAL_FCOEMTU,netdev->mtu)"
>and
>>  > send-down frames based on that?
>>
>> I think the point is that FCoE wants to use OPTIMAL_FCOEMTU (2KB + a
>bit
>> for headers) even when netdev->mtu is 1500.  (eg datacenter network
>> supports baby jumbo frames so FCoE traffic that stays within the
>network
>> should use OPTIMAL_FCOEMTU, while lots of IP traffic is going out
>onto a
>> 1500-byte MTU campus and having TCP doing lots of PMTU discovery is a
>> pain)
>
>Aren't all stations in the same broadcast domain "supposed" to have the
>same MTU,
>at least down at L2? So, a station in the broadcast domain just doing
>IP and a
>station in the broadcast domain doing IP+FCoE "should" have the same
>MTU at the
>HW level right?
It's still the same MTU to LAN, so two stations communicating by IP
still communicates on the LAN MTU (netdev->mtu) and FCoE using 2158
should be transparent to LAN. Of course, the corresponding NIC driver
needs to have the knowledge to set up correspondingly so HW can do
different MTUs. Ideally, I think this knowledge can be retrieved from
netdev as an additional MTU, say, netdev->fcoe_mtu, or something else,
thus LAN side will not be affected.

Thanks.

yi
