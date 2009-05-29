From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [net-next-2.6 PATCH 3/4] ixgbe: remove rx_hdr_split debug
 counter for non-debug configurations
Date: Thu, 28 May 2009 17:01:17 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F44CF8060@orsmsx501.amr.corp.intel.com>
References: <20090527005445.28535.9069.stgit@localhost.localdomain>
	<20090526.203810.50281143.davem@davemloft.net>
	<1243423017.16597.143.camel@deadeye>
 <20090527.135211.44614815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:8410 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754629AbZE2ABR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 20:01:17 -0400
In-Reply-To: <20090527.135211.44614815.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 27 May 2009 12:16:57 +0100
> 
>> If rx_hdr_split means the same thing at Intel as it does here, it's a
>> hardware feature Microsoft wants for use in Hyper-V and it won't be
>> enabled under Linux.
> 
> Nobody explains anything, so it could or it could not be, who knows.
> :-)

The feature mentioned here is header-data split.  When it is enabled the igb driver puts the header into skb data, and the remainder into the page frags list.  It is used when we enable jumbo frames on the igb driver.  The counter I had removed in the patch was keeping track of the split header bit which is 1 when the header size reflected in the descriptor is correct.

The counter didn't really have much use other than in our early validation work to make certain the silicon was working as documented.  If it stays it isn't too big a concern I just figured it might be nice to remove it since igb is a multiqueue driver and having a global counter can cause some cache thrash on multicore systems.

Thanks,

Alex