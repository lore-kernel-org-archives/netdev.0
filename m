From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [RFC PATCH 1/4] net: Add support to netdev ops for changing
	hardware queue MAC and VLAN filters
Date: Wed, 18 Nov 2009 23:14:25 +0000
Message-ID: <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
	 <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:30426 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbZKRXO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 18:14:28 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-11-18 at 14:37 -0700, Williams, Mitch A wrote:
> 
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Wednesday, November 18, 2009 11:53 AM
> 
> >How do you remove a filter?
> >
> 
> You remove a filter by setting it to 0 on that queue. Works for either MAC or VLAN.
> 
> >What about filtering on both MAC address and VLAN (our new controller
> >supports that)?
> 
> Setting a MAC filter doesn't blow away the VLAN filter, or vice-versa. So just run 'ip' twice to set the filters. Our hardware does it too, and it works fine for me:
> 
> $ ip link set eth1 queue 1 mac 00:11:22:33:44:55
> $ ip link set eth1 queue 1 vlan 10

Hmm, this is not what I would expect.  I'm used to filters being defined
independently of queues in a hash table or CAM.  In that case, setting
multiple filters pointing to one queue will result in the logical
disjunction of the filters.  Do I understand correctly that you have
exactly one of each type of filter per queue, with multiple filters
interpreted as a logical conjunction?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

