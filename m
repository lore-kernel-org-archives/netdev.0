From: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Subject: Re: [PATCH] isdnloop: NUL-terminate strings from userspace
Date: Tue, 01 Apr 2014 20:23:44 +0900
Message-ID: <533AA1C0.8030609@yoshifuji.org>
References: <1396346898-8950-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Vegard Nossum <vegard.nossum@oracle.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396346898-8950-1-git-send-email-vegard.nossum@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vegard Nossum wrote:
> Both the in-kernel and BSD strlcpy() require that the source string is
> NUL terminated. We could use strncpy() + explicitly terminate the result,
> but this relies on src and dest having the same size, so the safest thing
> to do seems to explicitly terminate the source string before doing the
> strlcpy().
:
> diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
> index 02125e6..50cd348 100644
> --- a/drivers/isdn/isdnloop/isdnloop.c
> +++ b/drivers/isdn/isdnloop/isdnloop.c
> @@ -1070,6 +1070,14 @@ isdnloop_start(isdnloop_card *card, isdnloop_sdef *sdefp)
>  		return -EBUSY;
>  	if (copy_from_user((char *) &sdef, (char *) sdefp, sizeof(sdef)))
>  		return -EFAULT;
> +
> +	/*
> +	 * Null terminate strings from userspace so we don't have to worry
> +	 * about this later on.
> +	 */
> +	for (i = 0; i < 3; i++)
> +		sdef.num[i][sizeof(sdef.num[0]) - 1] = '\0';
> +

Why don't we return -EINVAL if it is not correctly terminated by NUL?

--yoshfuji
