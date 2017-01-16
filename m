From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 1/7] sctp: add a common helper function to
 generate stream reconf chunk
Date: Mon, 16 Jan 2017 13:50:33 -0500 (EST)
Message-ID: <20170116.135033.773805315875747960.davem@davemloft.net>
References: <cover.1484334002.git.lucien.xin@gmail.com>
        <cover.1484334002.git.lucien.xin@gmail.com>
        <5f8a7d818b5db99f2ff2a791a451b311c09fad7f.1484334002.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46354 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdAPSuf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 13:50:35 -0500
In-Reply-To: <5f8a7d818b5db99f2ff2a791a451b311c09fad7f.1484334002.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 14 Jan 2017 03:15:35 +0800

> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index a15d824..fd58097 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3526,3 +3526,36 @@ struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
>  
>  	return retval;
>  }
> +
> +/* RE-CONFIG 3.1 (RE-CONFIG chunk)
> + *   0                   1                   2                   3
> + *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *  | Type = 130    |  Chunk Flags  |      Chunk Length             |
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *  \                                                               \
> + *  /                  Re-configuration Parameter                   /
> + *  \                                                               \
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + *  \                                                               \
> + *  /             Re-configuration Parameter (optional)             /
> + *  \                                                               \
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + */
> +static struct sctp_chunk *sctp_make_reconf(
> +				const struct sctp_association *asoc,
> +				int length)
> +{
> +	struct sctp_reconf_chunk *reconf;

This patch will cause a warning because this new static function is unused.

All patch series must be fully bisectable, that measn at each step of
the patch series the tree must work properly and not introduce new
build warnings or build failures.
