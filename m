From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: [PATCH 03/17] fs: don't allow to complete sync iocbs through
 aio_complete
Date: Tue, 14 Apr 2015 11:00:49 -0700
Message-ID: <552D55D1.2000908@intel.com>
References: <20150411211742.GJ889@ZenIV.linux.org.uk> <1428787108-13650-3-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>, davem@davemloft.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1428787108-13650-3-git-send-email-viro@ZenIV.linux.org.uk>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/11/2015 02:18 PM, Al Viro wrote:
> @@ -766,8 +765,7 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
>  
>  	init_sync_kiocb(&iocb, NULL);
>  	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
> -	if (-EIOCBQUEUED == ret)
> -		ret = wait_on_sync_kiocb(&iocb);
> +	BUG_ON(ret == -EIOCBQUEUED);

NACK - PF_ALG type sockets support async operations and return -EIOCBQUEUED
See skcipher_recvmsg_async() in crypto/algif_skcipher.c in net-next
