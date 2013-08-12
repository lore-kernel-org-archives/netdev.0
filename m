From: William Manley <william.manley@youview.com>
Subject: Re: [PATCH net-next] ipv6: make unsolicited report intervals configurable
 for mld
Date: Mon, 12 Aug 2013 11:16:34 +0100
Message-ID: <5208B602.4040107@youview.com>
References: <20130812014859.GA13886@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <bcrl@kvack.org>,
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:23165
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753030Ab3HLKb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 06:31:56 -0400
In-Reply-To: <20130812014859.GA13886@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/13 02:48, Hannes Frederic Sowa wrote:
> Commit cab70040dfd95ee32144f02fade64f0cb94f31a0 ("net: igmp:
> Reduce Unsolicited report interval to 1s when using IGMPv3") and
> 2690048c01f32bf45d1c1e1ab3079bc10ad2aea7 ("net: igmp: Allow user-space
> configuration of igmp unsolicited report interval") by William Manley made
> igmp unsolicited report intervals configurable per interface and corrected
> the interval of unsolicited igmpv3 report messages resendings to 1s.
>
> Same needs to be done for IPv6:
>
> MLDv1 (RFC2710 7.10.): 10 seconds
> MLDv2 (RFC3810 9.11.): 1 second
>
> Both intervals are configurable via new procfs knobs
> mldv1_unsolicited_report_interval and mldv2_unsolicited_report_interval.
>
> Cc: William Manley<william.manley@youview.com>
> Cc: Benjamin LaHaise<bcrl@kvack.org>
> Cc: YOSHIFUJI Hideaki<yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa<hannes@stressinduktion.org>

Thanks for this.  I'd meant to save you the bother.

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 7fd8572..158c5e1 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -177,6 +177,8 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
>   	.accept_redirects	= 1,
>   	.autoconf		= 1,
>   	.force_mld_version	= 0,
> +	.mldv1_unsolicited_report_interval = 10*HZ,

I think you want spaces around that * operator.

> +	.mldv2_unsolicited_report_interval = HZ,
>   	.dad_transmits		= 1,
>   	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
>   	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
> @@ -211,6 +213,9 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
>   	.accept_ra		= 1,
>   	.accept_redirects	= 1,
>   	.autoconf		= 1,
> +	.force_mld_version	= 0,

Is this a tidyup or does it make a functional difference to this patch? 
  I suspect the former but I thought I'd check for my own understanding.

> +	.mldv1_unsolicited_report_interval = 10*HZ,

Spaces here as well

Thanks

Will
