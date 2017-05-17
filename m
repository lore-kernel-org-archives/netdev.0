From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/7] skbuff: add stub to help computing
 crc32c on SCTP packets
Date: Wed, 17 May 2017 12:08:03 -0400 (EDT)
Message-ID: <20170517.120803.1777244523172583336.davem@davemloft.net>
References: <cover.1494946940.git.dcaratti@redhat.com>
        <970ffbc429b9297c3038f12f4b9cad1afbdbc375.1494946940.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        alexander.duyck@gmail.com, tom@herbertland.com,
        David.Laight@ACULAB.COM, marcelo.leitner@gmail.com
To: dcaratti@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdEQQIK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 12:08:10 -0400
In-Reply-To: <970ffbc429b9297c3038f12f4b9cad1afbdbc375.1494946940.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>
Date: Tue, 16 May 2017 18:27:45 +0200

> @@ -2243,6 +2243,30 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
>  }
>  EXPORT_SYMBOL(skb_copy_and_csum_bits);
>  
> +static __wsum warn_crc32c_csum_update(const void *buff, int len, __wsum sum)
> +{
> +	net_warn_ratelimited(
> +		"%s: attempt to compute crc32c without libcrc32c.ko\n",
> +		__func__);
> +	return 0;
> +}
> +
> +static __wsum warn_crc32c_csum_combine(__wsum csum, __wsum csum2,
> +				       int offset, int len)
> +{
> +	net_warn_ratelimited(
> +		"%s: attempt to compute crc32c without libcrc32c.ko\n",
> +		__func__);
> +	return 0;
> +}
> +
> +const struct skb_checksum_ops *crc32c_csum_stub __read_mostly =
> +	&(struct skb_checksum_ops) {
> +	.update  = warn_crc32c_csum_update,
> +	.combine = warn_crc32c_csum_combine,
> +};
> +EXPORT_SYMBOL(crc32c_csum_stub);

Please, if you are going to do this, declare things in a more
traditional and canonical way:

static const struct skb_checksum_ops default_crc32c_ops = {
	.update  = warn_crc32c_csum_update,
	.combine = warn_crc32c_csum_combine,
};

const struct skb_checksum_ops *crc32c_csum_stub __read_mostly =
	&default_crc32c_ops;

> +static const struct skb_checksum_ops *crc32c_csum_ops __read_mostly =
> +	&(struct skb_checksum_ops) {
> +	.update  = sctp_csum_update,
> +	.combine = sctp_csum_combine,
> +};

Likewise.
