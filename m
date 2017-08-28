From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 3/4] net/core: Add violation counters to VF
 statisctics
Date: Sun, 27 Aug 2017 20:43:06 -0400
Message-ID: <20170827204306.0fb98e31@cakuba>
References: <20170827110618.20599-1-saeedm@mellanox.com>
        <20170827110618.20599-4-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eugenia Emantayev <eugenia@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:37450 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751437AbdH1Ans (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:43:48 -0400
In-Reply-To: <20170827110618.20599-4-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 27 Aug 2017 14:06:17 +0300, Saeed Mahameed wrote:
> From: Eugenia Emantayev <eugenia@mellanox.com>
> 
> Add receive and transmit violation counters to be
> displayed in iproute2 VF statistics.
> 
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  include/linux/if_link.h      |  2 ++
>  include/uapi/linux/if_link.h |  2 ++
>  net/core/rtnetlink.c         | 10 +++++++++-
>  3 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index da70af27e42e..ebf3448acb5b 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -12,6 +12,8 @@ struct ifla_vf_stats {
>  	__u64 tx_bytes;
>  	__u64 broadcast;
>  	__u64 multicast;
> +	__u64 rx_dropped;
> +	__u64 tx_dropped;

I'm a little concerned that you call those violation counters in the
commit message.  Do you expect them to only be used if the VF traffic
indeed violates some admin-set rules?  I would imaging HW/FW may drop
frames in certain situations and naming the counters *_dropped suggests
it would be OK to increment them even if the drop reason was not any
sort of violation.  Would you mind clarifying?
