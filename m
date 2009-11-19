From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [RFC PATCH 1/4] net: Add support to netdev ops for changing
	hardware queue MAC and VLAN filters
Date: Thu, 19 Nov 2009 11:43:54 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FA6A1FF82@rrsmsx501.amr.corp.intel.com>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
	 <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>
	 <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A337F@rrsmsx501.amr.corp.intel.com>
 <1258642493.2837.8.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9850 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754223AbZKSSnu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 13:43:50 -0500
In-Reply-To: <1258642493.2837.8.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Thursday, November 19, 2009 6:55 AM


>[...]
>> In the case of SR-IOV on our hardware, these filters are perfect - no
>> hash tables are required. (We do use hash tables when we have a bunch
>> of multicast addresses, but that's not what this is about.)
>>
>> MAC filters deny packets by default, so you won't get anything without
>> a valid MAC filter on the queue.
>>
>> A queue with no VLAN filters will receive packets from all VLANs,
>> albeit with the tags passed up intact.  So in that sense, the VLAN
>> filters are default-allow.
>>
>> However, once you enable any VLAN filter, the hardware starts
>> stripping tags and begins to deny packets by default.
>>
>> Based on these semantics, the filtering operation that I've described
>> above makes perfect sense.
>[...]
>
>But they are not the semantics we would want in supposedly generic
>netdev operations.
>

OK, point taken.  Specific hardware features/limitations shouldn't affect kernel policy.

However, I'm still back to code complexity, and general usage models.

Please explain specifically what you perceive to be the difference between:

$ ip link set eth1 queue 1 mac <blah>
$ ip link set eth1 queue 1 vlan <foo>

and

$ ip link set eth1 queue 1 mac <blah> vlan <foo>

The two filter types are, in my mind, completely orthogonal.  You can have one, or the other, or both, or neither. What do we gain by glomming both options on one command line?  And is this worth the tradeoff of more complex code?

-Mitch

