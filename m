From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix uninitialized variable issue
Date: Tue, 15 Dec 2015 11:02:09 -0800
Message-ID: <1450206129.8474.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151215184617.11620.23369.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, freude@linux.vnet.ibm.com,
	viro@zeniv.linux.org.uk, linux-crypto@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20151215184617.11620.23369.stgit@tstruk-mobl1>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-12-15 at 10:46 -0800, Tadeusz Struk wrote:
> msg_iocb needs to be initialized on the recv/recvfrom path.
> Otherwise afalg will wrongly interpret it as an async call.
> 
> Cc: stable@vger.kernel.org
> Reported-by: Harald Freudenberger <freude@linux.vnet.ibm.com>
> Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
> ---
>  net/socket.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/socket.c b/net/socket.c
> index dd2c247..80ca820 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1702,6 +1702,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
>  	msg.msg_name = addr ? (struct sockaddr *)&address : NULL;
>  	/* We assume all kernel code knows the size of sockaddr_storage */
>  	msg.msg_namelen = 0;
> +	msg.msg_iocb = NULL;
>  	if (sock->file->f_flags & O_NONBLOCK)
>  		flags |= MSG_DONTWAIT;
>  	err = sock_recvmsg(sock, &msg, iov_iter_count(&msg.msg_iter), flags);
> 

Do not add "Cc: stable@vger.kernel.org" for networking patches, thanks 
( Documentation/networking/netdev-FAQ.txt )

Do you know when was this bug added ?

Please add the 

Fixes:  12-digit-sha1 ("patch title")

Thanks.
