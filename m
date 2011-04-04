From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH net-next-2.6 07/12] igbvf: remove bogus phys_id
Date: Mon, 4 Apr 2011 14:27:13 -0700
Message-ID: <43F901BD926A4E43B106BF17856F07550145CAFD30@orsmsx508.amr.corp.intel.com>
References: <20110404184340.604594357@linuxplumber.net>
 <20110404184501.915865252@linuxplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Br
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55046 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754194Ab1DDV1P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 17:27:15 -0400
In-Reply-To: <20110404184501.915865252@linuxplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Stephen Hemminger
> Sent: Monday, April 04, 2011 11:44 AM
> To: David S. Miller; Ben Hutchings; Kirsher, Jeffrey T; Brandeburg, Jesse;
> Allan, Bruce W; Wyborny, Carolyn; Skidmore, Donald C; Ronciak, John
> Cc: netdev@vger.kernel.org
> Subject: [PATCH net-next-2.6 07/12] igbvf: remove bogus phys_id
> 
> This device lies about supporting phys_id. Remove it and just
> let the upper layer report not supported.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/igbvf/ethtool.c	2011-04-04 11:15:50.477019338 -0700
> +++ b/drivers/net/igbvf/ethtool.c	2011-04-04 11:16:12.661202774 -0700
> @@ -391,11 +391,6 @@ static int igbvf_set_wol(struct net_devi
>  	return -EOPNOTSUPP;
>  }
> 
> -static int igbvf_phys_id(struct net_device *netdev, u32 data)
> -{
> -	return 0;
> -}
> -
>  static int igbvf_get_coalesce(struct net_device *netdev,
>                                struct ethtool_coalesce *ec)
>  {
> @@ -527,7 +522,6 @@ static const struct ethtool_ops igbvf_et
>  	.self_test		= igbvf_diag_test,
>  	.get_sset_count		= igbvf_get_sset_count,
>  	.get_strings		= igbvf_get_strings,
> -	.phys_id		= igbvf_phys_id,
>  	.get_ethtool_stats	= igbvf_get_ethtool_stats,
>  	.get_coalesce		= igbvf_get_coalesce,
>  	.set_coalesce		= igbvf_set_coalesce,

I would just like to note that many virtual devices lie about their underlying capabilities.  Many systems report having an Realtek adapter when in fact they don't.  I'm agnostic about this change but at one time I had an internal bug report because my VF driver *didn't* report phys_id.  I'll keep this email around if my tester writes up a big for me.

Regards,

- Greg

