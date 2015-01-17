From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [RFC PATCH net-next] bridge: ability to disable forwarding on a
 port
Date: Sat, 17 Jan 2015 21:14:10 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC3505DF57DB@ORSMSX101.amr.corp.intel.com>
References: <1421479975-62049-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "wkok@cumulusnetworks.com" <wkok@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:48033 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbbAQVOL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 16:14:11 -0500
In-Reply-To: <1421479975-62049-1-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: roopa@cumulusnetworks.com [mailto:roopa@cumulusnetworks.com]
>Sent: Friday, January 16, 2015 11:33 PM
>To: stephen@networkplumber.org; davem@davemloft.net; jhs@mojatatu.com;
>sfeldma@gmail.com; jiri@resnulli.us; Arad, Ronen; tgraf@suug.ch;
>john.fastabend@gmail.com; vyasevic@redhat.com
>Cc: netdev@vger.kernel.org; wkok@cumulusnetworks.com;
>gospo@cumulusnetworks.com
>Subject: [RFC PATCH net-next] bridge: ability to disable forwarding on a port
>
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>On a Linux bridge with bridge forwarding offloaded to a switch ASIC,
>there is a need to not re-forward the frames that come up to the
>kernel in software.
>
>Typically these are broadcast or multicast packets forwarded by the
>hardware to multiple destination ports including sending a copy of
>the packet to the kernel (e.g. an arp broadcast).
>The bridge driver will try to forward the packet again, resulting in
>two copies of the same packet.
>
>These packets can also come up to the kernel for logging when they hit
>a LOG acl in hardware.
>
>This patch makes forwarding a flag on the port similar to
>learn and flood and drops the packet just before forwarding.
>(The forwarding disable on a bridge is tested to work on our boxes.
>The bridge port flag addition is only compile tested.
>This will need to be further refined to cover cases where a non-switch port
>is bridged to a switch port etc. We will submit more patches to cover
>all cases if we agree on this approach).
>
>Other ways to solve the same problem could be to:
>- use the offload feature flag on these switch ports to avoid the
>re-forward:
>https://www.marc.info/?l=linux-netdev&m=141820235010603&w=2
>
>- Or the switch driver can mark or set a flag in the skb, which the bridge
>driver can use to avoid a re-forward.
>

The proposed patch does not go along with the offload feature flag.
The premise of the offload feature flag is that offloading is driven by the 
switch port driver without user intervention. This patch requires different
setting for BR_FLOOD in the software bridge port and the switch port driver.
The alternatives suggested (offload flag or skb flag) are better.

The proposed patch avoids re-forward but not without cost. For example in the
case of unicast flood with local destination, the skb is cloned for each port
before the forward avoidance in __br_forward. Is it acceptable overhead?
  
[...]
