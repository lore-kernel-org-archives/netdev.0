From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH V2 4/5] i40e/ethtool: support coalesce getting by queue
Date: Thu, 7 Jan 2016 22:19:19 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFE2A29@fmsmsx115.amr.corp.intel.com>
References: <1451912041-8860-1-git-send-email-kan.liang@intel.com>
 <1451912041-8860-4-git-send-email-kan.liang@intel.com>
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
Received: from mga11.intel.com ([192.55.52.93]:43343 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753194AbcAGWTV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 17:19:21 -0500
In-Reply-To: <1451912041-8860-4-git-send-email-kan.liang@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +
> +		q_vector = vsi->rx_rings[queue]->q_vector;
> +		vector = vsi->base_vector + q_vector->v_idx;
> +		ec->rx_coalesce_usecs = ITR_REG_TO_USEC(rd32(hw, I40E_PFINT_ITRN(0, vector - 1)));

Use I40E_RX_ITR rather than the hardcoded 0

> +
> +		q_vector = vsi->tx_rings[queue]->q_vector;
> +		vector = vsi->base_vector + q_vector->v_idx;
> +		ec->tx_coalesce_usecs = ITR_REG_TO_USEC(rd32(hw, I40E_PFINT_ITRN(1, vector - 1)));

Use I40E_TX_ITR rather than the hardcoded 1

Other than that, yes, this looks like the right translation to get to the itr register you want.

sln
