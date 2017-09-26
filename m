From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/tls: move version check after second userspace
 fetch
Date: Tue, 26 Sep 2017 11:37:27 -0700 (PDT)
Message-ID: <20170926.113727.1747580838880526105.davem@davemloft.net>
References: <1506266095-23003-1-git-send-email-mengxu.gatech@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilyal@mellanox.com, aviadye@mellanox.com, davejwatson@fb.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        meng.xu@gatech.edu, sanidhya@gatech.edu, taesoo@gatech.edu
To: mengxu.gatech@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506266095-23003-1-git-send-email-mengxu.gatech@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Meng Xu <mengxu.gatech@gmail.com>
Date: Sun, 24 Sep 2017 11:14:55 -0400

> @@ -382,6 +376,12 @@ static int do_tls_setsockopt_tx(struct sock *sk, char __user *optval,
>  			rc = -EFAULT;
>  			goto err_crypto_info;
>  		}
> +
> +		/* check version */
> +		if (crypto_info->version != TLS_1_2_VERSION) {
> +			rc = -ENOTSUPP;
> +			goto err_crypto_info;
> +		}
>  		break;
>  	}
>  	default:
> -- 
> 2.7.4
> 

Please, again, deduce this into a single userspace copy.  Otherwise we're going to
add this check for every cipher we add new support for.

Copy the on-stack crypto info ("tmp_crypto_info") into 'crypto_info' and then
bring in from userspace any further bytes that need to be copied.

That guarantees that the version will not change, and the existing check can
stay where it is.
