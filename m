From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH NET] ethtool: silence warning on bit loss
Date: Fri, 14 Oct 2016 09:26:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB01E8624@AcuExch.aculab.com>
References: <1476400435-18400-1-git-send-email-jesse.brandeburg@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Jesse Brandeburg' <jesse.brandeburg@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:63176 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752903AbcJNJaU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 05:30:20 -0400
In-Reply-To: <1476400435-18400-1-git-send-email-jesse.brandeburg@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg
> Sent: 14 October 2016 00:14
> Sparse was complaining when we went to prototype some code
> using ethtool_cmd_speed_set and SPEED_100000, which uses
> the upper 16 bits of __u32 speed for the first time.
...
> Reported-by: Preethi Banala <preethi.banala@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> ---
>  include/uapi/linux/ethtool.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 099a420..8e54723 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -119,8 +119,7 @@ struct ethtool_cmd {
>  static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
>  					 __u32 speed)
>  {
> -
> -	ep->speed = (__u16)speed;
> +	ep->speed = (__u16)(speed & 0xFFFF);
>  	ep->speed_hi = (__u16)(speed >> 16);

I suspect that deleting both (__u16) casts also fixes it?

	David
