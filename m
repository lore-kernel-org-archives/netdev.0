From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: pre-clear the returned sockaddr_storage variable
Date: Tue, 09 Apr 2013 11:10:21 -0700
Message-ID: <1365531021.3887.151.camel@edumazet-glaptop>
References: <20130409175024.GA19308@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>,
	Brad Spengler <spender@grsecurity.net>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130409175024.GA19308@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-04-09 at 10:50 -0700, Kees Cook wrote:
> To avoid future stack content leaks in the various protocols, pre-clear
> the returned memory.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Suggested-by: Brad Spengler <spender@grsecurity.net>
> ---
>  net/socket.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/socket.c b/net/socket.c
> index 88f759a..4d2af0d 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1838,7 +1838,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
>  	struct socket *sock;
>  	struct iovec iov;
>  	struct msghdr msg;
> -	struct sockaddr_storage address;
> +	struct sockaddr_storage address = { };
>  	int err, err2;
>  	int fput_needed;
>  
> @@ -2185,7 +2185,7 @@ static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
>  	int err, total_len, len;
>  
>  	/* kernel mode address */
> -	struct sockaddr_storage addr;
> +	struct sockaddr_storage addr = { };
>  
>  	/* user mode address pointers */
>  	struct sockaddr __user *uaddr;
> -- 
> 1.7.9.5
> 
> 

Nack, for obvious performance reasons.
