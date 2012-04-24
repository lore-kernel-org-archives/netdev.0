From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/3] Add capability to retrieve plug-in module
 EEPROM
Date: Tue, 24 Apr 2012 18:29:05 +0100
Message-ID: <1335288545.17274.35.camel@bwh-desktop.uk.solarflarecom.com>
References: <4F9031CE.1060702@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bruce.w.allan@intel.com>,
	<decot@google.com>, <alexander.h.duyck@intel.com>,
	<davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Stuart Hodgson <smhodgson@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36815 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756733Ab2DXR3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 13:29:15 -0400
In-Reply-To: <4F9031CE.1060702@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 16:39 +0100, Stuart Hodgson wrote:
> Provides a new struct ethtool_modinfo that will return the
> type and size of plug-in module eeprom (such as SFP+) for parsing
> by userland program.
> 
> The second provides the API to get the raw eeprom information
> using the existing ethtool_eeprom structture to return the data
> 
> Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
> ---
>  include/linux/ethtool.h |   33 +++++++++++++++++++++++++++++++++
>  net/core/ethtool.c      |   47 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 80 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 89d68d8..f6500f3 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -137,6 +137,23 @@ struct ethtool_eeprom {
>  };
> 
>  /**
> + * struct ethtool_modinfo - plugin module eeprom information
> + * @cmd: ETHTOOL_GMODULEINFO
> + * @type: Standard the module information conforms to SFF_xxxx

You renamed the type codes to begin with 'ETH_MODULE_SFF_', so this line
needs to be updated too.

> + * @eeprom_len: Length of the eeprom
> + *
> + * This structure is used to return the information to
> + * properly size memory for a subsequent call to ETHTOOL_GMODULEEEPROM
[...]

The type code is also essential in order to parse the information.

Also, a minor nitpick: you should put a '%' in front of the names of
constants so they can be pretty-printed properly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
