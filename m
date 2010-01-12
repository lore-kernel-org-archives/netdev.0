From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [net-next-2.6 PATCH 3/5] ethtool: Introduce n-tuple filter
	programming support
Date: Tue, 12 Jan 2010 11:13:54 -0800
Message-ID: <F86E8680A7D9D74A99DC6345E35A692950109528@orsmsx503.amr.corp.intel.com>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
	 <20100107044905.28605.54076.stgit@localhost.localdomain>
 <1263238353.2781.38.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, Luca Deri <deri@ntop.org>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50287 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433Ab0ALTNy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 14:13:54 -0500
In-Reply-To: <1263238353.2781.38.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Monday, January 11, 2010 11:33 AM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
>Waskiewicz Jr, Peter P; Luca Deri; Gasparakis, Joseph
>Subject: Re: [net-next-2.6 PATCH 3/5] ethtool: Introduce n-tuple filter
>programming support
>
>On Wed, 2010-01-06 at 20:49 -0800, Jeff Kirsher wrote:
>> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
>>
>> This patchset enables the ethtool layer to program n-tuple
>> filters to an underlying device.  The idea is to allow capable
>> hardware to have static rules applied that can assist steering
>> flows into appropriate queues.
>[...]
>> @@ -500,6 +529,8 @@ struct ethtool_ops {
>>  	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
>>  	int     (*flash_device)(struct net_device *, struct ethtool_flash
>*);
>>  	int	(*reset)(struct net_device *, u32 *);
>> +	int	(*set_rx_ntuple)(struct net_device *, struct
>ethtool_rx_ntuple *);
>> +	int	(*get_rx_ntuple)(struct net_device *, struct
>ethtool_rx_ntuple *, void *);
>>  };
>>  #endif /* __KERNEL__ */
>>
>[...]
>
>It it really necessary to add new driver operations?  It seems to me
>that it would be preferable to extend {get,set}_rx_nfc() and have the
>ethtool common code convert between the ethtool_rxnfc and
>ethtool_rx_ntuple structures.  Does that seem possible?
>

It is possible, but I'm not sure if it's the right way to go.  The nfc routines are just flipping the various engines on in niu, where the ntuple routines are for passing full amounts of data through for different filters.  Also, I think keeping them separate makes niu programming cleaner, which can support both the nfc and ntuple modes.

Cheers,
-PJ
