From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH NEXT 1/2] net: add external loopback test in ethtool
 self test
Date: Wed, 29 Jun 2011 19:28:59 +0100
Message-ID: <1309372139.2714.6.camel@bwh-desktop>
References: <1309243247-15950-1-git-send-email-amit.salecha@qlogic.com>
	 <1309243247-15950-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:19107 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756891Ab1F2S3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 14:29:03 -0400
In-Reply-To: <1309243247-15950-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-27 at 23:40 -0700, amit.salecha@qlogic.com wrote:
> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> External loopback test can be performed by application without any driver
> support on normal Ethernet cards.
> But on CNA devices, where multiple functions share same physical port.
> Here internal loopback test and external loopback test can be initiated by
> different function at same time. To co exist all functions, firmware need
> to regulate what test can be run by which function. So before performing external
> loopback test, command need to send to firmware, which will quiescent other functions.
> 
> User may not want to run external loopback test always. As special cable need to be
> connected for this test.
> 
> So adding explicit flag in ethtool self test, which will specify interface
> to perform external loopback test.

The trouble with adding flags to enum ethtool_test_flags is that there
is really no general way to tell whether the driver understood the flag.

I think you need to add a second flag which the driver sets to confirm
that it *did* use external loopback.

> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> ---
>  include/linux/ethtool.h |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 048d0fa..c2ba287 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -310,9 +310,18 @@ struct ethtool_sset_info {
>  				   __u32's, etc. */
>  };
>  
> +/*
> + * Flags definition of ethtool_test
> + *
> + * ETH_TEST_FL_OFFLINE:  online / offline
> + * ETH_TEST_FL_FAILED: test passed / failed
> + * ETH_TEST_FL_EXTERNAL_LB: perform external loopback test
> + */
> +

Replacing the inline comments with a block comment is fine, but please
use kernel-doc format.

Ben.

>  enum ethtool_test_flags {
> -	ETH_TEST_FL_OFFLINE	= (1 << 0),	/* online / offline */
> -	ETH_TEST_FL_FAILED	= (1 << 1),	/* test passed / failed */
> +	ETH_TEST_FL_OFFLINE	= (1 << 0),
> +	ETH_TEST_FL_FAILED	= (1 << 1),
> +	ETH_TEST_FL_EXTERNAL_LB	= (1 << 2),
>  };
>  
>  /* for requesting NIC test and getting results*/

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

