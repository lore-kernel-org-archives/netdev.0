From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [RFC PATCH 1/4] net: Add support to netdev ops for changing
	hardware queue MAC and VLAN filters
Date: Wed, 18 Nov 2009 14:37:32 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
 <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54359 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755865AbZKRVh3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 16:37:29 -0500
In-Reply-To: <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Wednesday, November 18, 2009 11:53 AM

>How do you remove a filter?
>

You remove a filter by setting it to 0 on that queue. Works for either MAC or VLAN.

>What about filtering on both MAC address and VLAN (our new controller
>supports that)?

Setting a MAC filter doesn't blow away the VLAN filter, or vice-versa. So just run 'ip' twice to set the filters. Our hardware does it too, and it works fine for me:

$ ip link set eth1 queue 1 mac 00:11:22:33:44:55
$ ip link set eth1 queue 1 vlan 10

-Mitch
