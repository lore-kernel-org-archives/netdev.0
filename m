From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/9] net-ethtool: Convert (hw_/vlan_/wanted_)features
 fields from u32 type to u64.
Date: Sun, 24 Apr 2011 06:30:40 +0100
Message-ID: <1303623041.3032.97.camel@localhost>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
	 <1303515367-25595-2-git-send-email-maheshb@google.com>
	 <1303515367-25595-3-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:1301 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742Ab1DXFaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 01:30:52 -0400
In-Reply-To: <1303515367-25595-3-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-22 at 16:36 -0700, Mahesh Bandewar wrote:
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  include/linux/ethtool.h |   26 +++++++------
>  net/core/ethtool.c      |   89 ++++++++++++++++------------------------------
>  2 files changed, 45 insertions(+), 70 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 9de3127..71e8a02 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -605,10 +605,10 @@ struct ethtool_flash {
>   * @never_changed: mask of features not changeable for any device
>   */
>  struct ethtool_get_features_block {
> -	__u32	available;
> -	__u32	requested;
> -	__u32	active;
> -	__u32	never_changed;
> +	__u64	available;
> +	__u64	requested;
> +	__u64	active;
> +	__u64	never_changed;
>  };
>  
>  /**
> @@ -618,10 +618,11 @@ struct ethtool_get_features_block {
>   *       out: number of elements in features[] needed to hold all features
>   * @features: state of features
>   */
> +/* TODO Why is this needed XXX */

Precisely to allow for expansion to more than 32 bits.

>  struct ethtool_gfeatures {
>  	__u32	cmd;
>  	__u32	size;
> -	struct ethtool_get_features_block features[0];
> +	struct ethtool_get_features_block features;
>  };
>  
>  /**
> @@ -630,8 +631,8 @@ struct ethtool_gfeatures {
>   * @requested: values of features to be changed
>   */
>  struct ethtool_set_features_block {
> -	__u32	valid;
> -	__u32	requested;
> +	__u64	valid;
> +	__u64	requested;
>  };
>  
>  /**
> @@ -640,10 +641,11 @@ struct ethtool_set_features_block {
>   * @size: array size of the features[] array
>   * @features: feature change masks
>   */
> +/* TODO Why is this needed XXX */
>  struct ethtool_sfeatures {
>  	__u32	cmd;
>  	__u32	size;
> -	struct ethtool_set_features_block features[0];
> +	struct ethtool_set_features_block features;
>  };
[...]

These structures are part of the userland API, but they are new in
2.6.39.  So they can still be changed up until 2.6.39 is released, but
not afterwards.

If we think 64 bits will be enough for the next 10 years, then let's
just go with a single 64-bit feature word.  If we're not so sure then
then the ethtool API should continue to allow for multiple words
(whether 32-bit or 64-bit).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

