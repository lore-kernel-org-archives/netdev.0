From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH 1/4] net: Add support to netdev ops for changing	hardware
 queue MAC and VLAN filters
Date: Thu, 19 Nov 2009 19:58:43 +0100
Message-ID: <4B059563.3010702@trash.net>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>	 <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>	 <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>	 <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>	 <EA929A9653AAE14F841771FB1DE5A1365FA69A337F@rrsmsx501.amr.corp.intel.com> <1258642493.2837.8.camel@achroite.uk.solarflarecom.com> <EA929A9653AAE14F841771FB1DE5A1365FA6A1FF82@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48978 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbZKSS6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 13:58:38 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FA6A1FF82@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Williams, Mitch A wrote:
> However, I'm still back to code complexity, and general usage models.
> 
> Please explain specifically what you perceive to be the difference between:
> 
> $ ip link set eth1 queue 1 mac <blah>
> $ ip link set eth1 queue 1 vlan <foo>
> 
> and
> 
> $ ip link set eth1 queue 1 mac <blah> vlan <foo>
> 
> The two filter types are, in my mind, completely orthogonal.  You can have one, or the other, or both, or neither. What do we gain by glomming both options on one command line?  And is this worth the tradeoff of more complex code?

One argument would be that "ip link show" should probably display
all filters, so they all need to be included in the dump message.

And this is exactly the same message type used for configuring
links and the API is supposed to be symetric, meaning you can
send a dump message with NLM_F_REQUEST to the kernel again and
it (re-)creates the same object.

