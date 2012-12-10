From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet_diag: validate port comparison byte code to
 prevent unsafe reads
Date: Sun, 09 Dec 2012 19:02:23 -0500 (EST)
Message-ID: <20121209.190223.1179297442063515404.davem@davemloft.net>
References: <1355086980-30438-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999Ab2LJACZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 19:02:25 -0500
In-Reply-To: <1355086980-30438-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun,  9 Dec 2012 16:03:00 -0500

> Add logic to verify that a port comparison byte code operation
> actually has the second inet_diag_bc_op from which we read the port
> for such operations.
> 
> Previously the code blindly referenced op[1] without first checking
> whether a second inet_diag_bc_op struct could fit there. So a
> malicious user could make the kernel read 4 bytes beyond the end of
> the bytecode array by claiming to have a whole port comparison byte
> code (2 inet_diag_bc_op structs) when in fact the bytecode was not
> long enough to hold both.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Haste makes waste...

> +/* Validate a port comparison operator. */
> +static inline bool valid_port_comparison(const struct inet_diag_bc_op *op,
> +					 int len, int *min_len)
> +{
> +	/* Port comparisons put the port in a follow-on inet_diag_bc_op. */
> +	*min_len += sizeof(struct inet_diag_bc_op);
> +	if (len < *min_len)
> +		return false;
> +}
> +

I added the missing "return true" at the end of this new function.

Applied, but please be more careful and at least look at the compiler
warnings when you submit your changes.

Thanks.
