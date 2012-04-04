From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next V6 7/8] net/dcb: Add an optional max rate attribute
Date: Wed, 04 Apr 2012 08:48:12 -0700
Message-ID: <4F7C6D3C.7070807@intel.com>
References: <1333537084-9186-1-git-send-email-amirv@mellanox.com> <1333537084-9186-8-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6025 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756415Ab2DDPsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 11:48:14 -0400
In-Reply-To: <1333537084-9186-8-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/2012 3:58 AM, Amir Vadai wrote:
> Although not specified in 8021Qaz spec, it could be useful to enable drivers
> whose HW supports setting a rate limit for an ETS TC. This patch adds this
> optional attribute to DCB netlink. To use it, drivers should implement and
> register the callbacks ieee_setmaxrate and ieee_getmaxrate. The units are 64
> bits long and specified in Kbps to enable usage over both slow and very fast
> networks.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  include/linux/dcbnl.h |    5 +++++
>  include/net/dcbnl.h   |    2 ++
>  net/dcb/dcbnl.c       |   21 +++++++++++++++++++++
>  3 files changed, 28 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
> index 65a2562..ec8e372 100644
> --- a/include/linux/dcbnl.h
> +++ b/include/linux/dcbnl.h
> @@ -67,6 +67,10 @@ struct ieee_ets {
>  	__u8	reco_prio_tc[IEEE_8021QAZ_MAX_TCS];
>  };
>  
> +struct ieee_maxrate {
> +	__u64	tc_maxrate[IEEE_8021QAZ_MAX_TCS];
> +};
> +

And I think the last comment. We really should have a comment here describing
what the tc_maxrate field is. Its described in the commit log but its much
harder for implementers to get it wrong when the struct is annotated.

Thanks!
John
