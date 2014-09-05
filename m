From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] irda: vlsi_ir: use %*ph specifier
Date: Fri, 05 Sep 2014 21:21:08 +0400
Message-ID: <5409F104.5040705@cogentembedded.com>
References: <1409927840-28791-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:52332 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335AbaIERVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 13:21:12 -0400
Received: by mail-lb0-f171.google.com with SMTP id 10so5038151lbg.30
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 10:21:10 -0700 (PDT)
In-Reply-To: <1409927840-28791-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/05/2014 06:37 PM, Andy Shevchenko wrote:

> Instead of looping in the code let's use kernel extension to dump small
> buffers.

> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>   drivers/net/irda/vlsi_ir.c | 11 +++--------
>   1 file changed, 3 insertions(+), 8 deletions(-)

> diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
> index a04af9d..0319eba 100644
> --- a/drivers/net/irda/vlsi_ir.c
> +++ b/drivers/net/irda/vlsi_ir.c
> @@ -323,14 +323,9 @@ static void vlsi_proc_ring(struct seq_file *seq, struct vlsi_ring *r)
>   		j = (unsigned) rd_get_count(rd);
>   		seq_printf(seq, "current: rd = %d / status = %02x / len = %u\n",
>   				h, (unsigned)rd_get_status(rd), j);
> -		if (j > 0) {
> -			seq_printf(seq, "   data:");
> -			if (j > 20)
> -				j = 20;
> -			for (i = 0; i < j; i++)
> -				seq_printf(seq, " %02x", (unsigned)((unsigned char *)rd->buf)[i]);
> -			seq_printf(seq, "\n");
> -		}
> +		if (j > 0)
> +			seq_printf(seq, "   data: %*ph\n", j > 20 ? 20 : j,

    Why not min(j, 20)?

> +				   rd->buf);
>   	}

WBR, Sergei
