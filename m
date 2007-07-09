From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Allow LSM to use IP address/port number.
Date: Mon, 09 Jul 2007 00:26:29 -0700 (PDT)
Message-ID: <20070709.002629.28788394.davem@davemloft.net>
References: <200707070225.AFC45609.MNStNTPG@I-love.SAKURA.ne.jp>
	<200707061343.03942.paul.moore@hp.com>
	<200707090533.l695X1PM059672@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	chrisw@sous-sol.org
To: from-netdev@i-love.sakura.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200707090533.l695X1PM059672@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <from-netdev@i-love.sakura.ne.jp>
Date: Mon, 09 Jul 2007 14:33:01 +0900

> @@ -649,8 +660,16 @@ int sock_recvmsg(struct socket *sock, st
>  	init_sync_kiocb(&iocb, NULL);
>  	iocb.private = &siocb;
>  	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
> -	if (-EIOCBQUEUED == ret)
> +	if (-EIOCBQUEUED == ret) {
>  		ret = wait_on_sync_kiocb(&iocb);
> +		/* I can now check security_socket_post_recvmsg(). */
> +		if (ret >= 0) {
> +			int err = security_socket_post_recvmsg(sock, msg, size,
> +							       flags);
> +			if (err)
> +				ret = err;
> +		}
> +	}
>  	return ret;
>  }

I don't think it's such a hot idea to return errors if the
wait_on_sync_kiocb() has returned success.

