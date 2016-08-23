From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: diag: slightly refactor the
 inet_diag_bc_audit error checks.
Date: Tue, 23 Aug 2016 11:31:27 -0700
Message-ID: <1471977087.14381.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471975571-26612-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
        davem@davemloft.net
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33102 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751710AbcHWScW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:32:22 -0400
Received: by mail-pa0-f65.google.com with SMTP id vy10so10300540pac.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:31:29 -0700 (PDT)
In-Reply-To: <1471975571-26612-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-24 at 03:06 +0900, Lorenzo Colitti wrote:
> This simplifies the code a bit and also allows inet_diag_bc_audit
> to send to userspace an error that isn't EINVAL.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  net/ipv4/inet_diag.c | 35 ++++++++++++++++++++++++-----------
>  1 file changed, 24 insertions(+), 11 deletions(-)
> 
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 38c2c47..a835f94 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -706,10 +706,23 @@ static bool valid_port_comparison(const struct inet_diag_bc_op *op,
>  	return true;
>  }
>  
> -static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
> +static bool valid_markcond(const struct inet_diag_bc_op *op, int len,
> +			   int *min_len)
>  {
> -	const void *bc = bytecode;
> -	int  len = bytecode_len;
> +	*min_len += sizeof(struct inet_diag_markcond);
> +	return len >= *min_len;
> +}

I do not see how this can compile, since you introduce "struct
inet_diag_markcond" in the following patch ?
