From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: update get_rx_ntuple to
 correctly interpret string count
Date: Wed, 05 Jan 2011 00:01:02 +0000
Message-ID: <1294185662.3636.61.camel@bwh-desktop>
References: <20110104232947.3451.91153.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42173 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab1AEABF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 19:01:05 -0500
In-Reply-To: <20110104232947.3451.91153.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-04 at 15:29 -0800, Alexander Duyck wrote:
> Currently any strings returned via the get_rx_ntuple call will just be
> dropped because the num_strings will be zero.  In order to correct this I
> am updating things so that the return value of get_rx_ntuple is the number
> of strings that were written, or a negative value if there was an error.
[...]

Nothing implements ethtool_ops::get_rx_ntuple, anyway.

The fallback implementation is totally bogus, too.  Maximum of 1024
filters?  Erm, sfc can handle more than that.  And doing complex string
formatting in the kernel, even though all the parsing is in ethtool?

Please, let's write off ETHTOOL_GRXNTUPLE as a failed experiment and
replace it with a command that behaves more like ETHTOOL_GRXCLSRLALL.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

