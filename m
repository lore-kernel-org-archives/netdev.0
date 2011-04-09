From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] v2 ethtool: add ntuple flow specifier
 data to network flow classifier
Date: Sat, 09 Apr 2011 01:13:06 +0100
Message-ID: <1302307986.2871.65.camel@bwh-desktop>
References: <20110408223451.27132.31805.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, Santwona Behera <santwona.behera@sun.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7981 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419Ab1DIANK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 20:13:10 -0400
In-Reply-To: <20110408223451.27132.31805.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-08 at 15:34 -0700, Alexander Duyck wrote:
> This change is meant to add an ntuple data extensions to the rx network flow
> classification specifiers.  The idea is to allow ntuple to be displayed via
> the network flow classification interface.
[...]
>  /**
>   * struct ethtool_rx_flow_spec - specification for RX flow filter
>   * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
>   * @h_u: Flow fields to match (dependent on @flow_type)
> + * @h_ext: Additional fields to match
>   * @m_u: Masks for flow field bits to be ignored
> + * @m_ext: Masks for additional field bits to be ignored.
> + *	Note, all additional fields must be ignored unless @flow_type
> + *	includes the %FLOW_EXT flag.
[...]

Sorry I didn't bring this up against v1:

I think you worked out that these masks are interpreted as bits to be
matched, rather than bits to be ignored, in the existing implementation
in niu.  Looking again at niu, I think that you were right about that.
So please fix the comment while you're updating it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

