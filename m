From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH V2 5/5] i40e/ethtool: support coalesce setting by queue
Date: Wed, 13 Jan 2016 18:19:30 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFE4C1F@fmsmsx115.amr.corp.intel.com>
References: <1451912041-8860-1-git-send-email-kan.liang@intel.com>
 <1451912041-8860-5-git-send-email-kan.liang@intel.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFE2A3B@fmsmsx115.amr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0770586E7D8@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"cascardo@redhat.com" <cascardo@redhat.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"ben@decadent.org.uk" <ben@decadent.org
To: "Liang, Kan" <kan.liang@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:51598 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755846AbcAMSTc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 13:19:32 -0500
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F0770586E7D8@SHSMSX103.ccr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Liang, Kan
> >
> > This looks reasonable, but be aware that since there's no concept of
> > queue-specific settings in the driver proper, these settings will get
> lost on
> > the next reset - see i40e_vsi_configure_msix().  A reset can be driven
> by a
> > number of things such as MTU changes, LLDP events, tx timeout recovery,
> > promiscuous on/off, and various other configuration changes.  This might
> > not be acceptable for your needs.
> >
> 
> Yes, the reset could be an issue.
> I guess we may make the concept of queue-specific settings for i40e by
> moving
> rx_itr_setting and tx_itr_setting to i40e_ring.
> 
> How about the patch as below?
> The patch only move itr_setting from i40e_vsi to i40e_ring.
> There should be no behavior change.
> 

Thanks, I finally had a chance to look through this.  On an initial read-through, yes, this would probably take care of it.

sln
