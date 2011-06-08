From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] v2 ethtool: remove support for ETHTOOL_GRXNTUPLE
Date: Wed, 08 Jun 2011 16:45:09 -0700 (PDT)
Message-ID: <20110608.164509.1093080552984966542.davem@davemloft.net>
References: <20110608223508.20551.45558.stgit@gitlad.jf.intel.com>
	<1307574227.22348.501.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755011Ab1FHXpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 19:45:12 -0400
In-Reply-To: <1307574227.22348.501.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 09 Jun 2011 00:03:47 +0100

> On Wed, 2011-06-08 at 15:35 -0700, Alexander Duyck wrote:
>> This change is meant to remove all support for displaying an ntuple as
>> strings via ETHTOOL_GRXNTUPLE.  The reason for this change is due to the
>> fact that multiple issues have been found including:
>>  - Multiple buffer overruns for strings being displayed.
>>  - Incorrect filters displayed, cleared filters with ring of -2 are displayed
>>  - Setting get_rx_ntuple displays no rules if defined.
>>  - Endianess wrong on displayed values.
>>  - Hard limit of 1024 filters makes display functionality extremely limited
>> 
>> The only driver that had supported this interface was ixgbe.  Since it no
>> longer uses the interface and due to the issues mentioned above I am
>> submitting this patch to remove it.
>> 
>> v2:
>> Updated based on comments from Ben Hutchings
>>  - Left ETH_SS_NTUPLE_FILTERS in code but commented on it being deprecated
>>  - Removed ethtool_rx_ntuple_list and ethtool_rx_ntuple_flow_spec_container
>>  - Left ETHTOOL_GRXNTUPLE but commented it as deprecated
>> 
>> Also cleaned up set_rx_ntuple since there is no flow spec container to
>> maintain we can drop all the code for the alloc and free of it and just
>> return ops->set_rx_ntuple().
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

I'll apply this to net-next-2.6, thanks!
