From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 2/2] Add support for ESP as a separate protocol
 from AH
Date: Sat, 09 Apr 2011 00:10:14 +0100
Message-ID: <1302304214.2871.52.camel@bwh-desktop>
References: <20110408221135.26893.50092.stgit@gitlad.jf.intel.com>
	 <20110408221239.26893.36898.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3941 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757377Ab1DHXKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 19:10:18 -0400
In-Reply-To: <20110408221239.26893.36898.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-08 at 15:12 -0700, Alexander Duyck wrote:
> This change is meant to split out ESP from AH.  Currently they are present
> as both a combined value, and two separate values.  In order to try and
> support eventually splitting the two out into separate values this change
> makes it so that ESP can be called out separately in ethtool.
[...]

The split between AH and ESP flows is one of several backward-
incompatible changes that Santwona made to RXNFC when adding flow
steering (originally it just dealt with hashing).

1. cxgb4, sfc and earlier versions of niu recognise AH_ESP_V{4,6}_FLOW
class codes for reporting of flow hashing.  niu also allowed it to be
controlled.

2. Later versions of niu recognise the separate AH and ESP flow class
codes.  gianfar also recognises them, but silently ignores any attempt
to control them!

We should make niu accept AH_ESP_V{4,6}_FLOW again for reporting and
control of flow hashing.  ethtool should use class codes
{AH,ESP}_V{4,6}_FLOW for flow steering, but not for flow hashing.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

