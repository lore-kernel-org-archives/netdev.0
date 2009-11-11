From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2/2] rps: changes to bnx2x to get device hash
Date: Wed, 11 Nov 2009 15:21:03 -0800
Message-ID: <20091111232103.GA1217@xw6200.broadcom.net>
References: <65634d660911102253lbfc0927i4e4c0eba6d7d765d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tom Herbert" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3808 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759637AbZKKXXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 18:23:32 -0500
In-Reply-To: <65634d660911102253lbfc0927i4e4c0eba6d7d765d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 10:53:36PM -0800, Tom Herbert wrote:
> @@ -6223,9 +6257,10 @@ static int bnx2x_init_common(struct bnx2x *bp)
>  	bnx2x_init_block(bp, PBF_BLOCK, COMMON_STAGE);
> 
>  	REG_WR(bp, SRC_REG_SOFT_RST, 1);
> -	for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4) {
> -		REG_WR(bp, i, 0xc0cac01a);
> -		/* TODO: replace with something meaningful */
> +	{
> +		int i;
> +		for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4)
> +			REG_WR(bp, i, random32());
>  	}
>  	bnx2x_init_block(bp, SRCH_BLOCK, COMMON_STAGE);
>  #ifdef BCM_CNIC

Is a random hash key really better than arbitrary static values?  
Setting the hash key to random values means, from chip reset to chip
reset, you could get different performance results.  Unless we
we understood how the key affects performance, I would think that
reproducable performance numbers would be more desirable, no?

