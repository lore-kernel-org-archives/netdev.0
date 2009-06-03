From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Question regarding protocol specific mtu for FCoE
Date: Wed, 03 Jun 2009 14:21:11 -0700
Message-ID: <adazlcp814o.fsf@cisco.com>
References: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>
	<4A26BAF7.3070301@hp.com>
	<7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>
	<4A26E4AE.4020607@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Zou\, Yi" <yi.zou@intel.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi\@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Leech\, Christopher" <christopher.leech@intel.com>,
	"Dev\, Vasu" <vasu.dev@intel.com>,
	"Love\, Robert W" <robert.w.love@intel.com>,
	"Ma\, Steve" <steve.ma@intel.com>,
	"Waskiewicz Jr\, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher\, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:58267 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbZFCVVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:21:09 -0400
In-Reply-To: <4A26E4AE.4020607@hp.com> (Rick Jones's message of "Wed, 03 Jun
	2009 14:01:34 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > So FCoE cannot say "fcoe_mtu = min(OPTIMAL_FCOEMTU,netdev->mtu)" and
 > send-down frames based on that?

I think the point is that FCoE wants to use OPTIMAL_FCOEMTU (2KB + a bit
for headers) even when netdev->mtu is 1500.  (eg datacenter network
supports baby jumbo frames so FCoE traffic that stays within the network
should use OPTIMAL_FCOEMTU, while lots of IP traffic is going out onto a
1500-byte MTU campus and having TCP doing lots of PMTU discovery is a
pain)

 - R.
