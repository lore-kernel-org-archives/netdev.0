From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: recvmsg: Unconditionally zero struct
 sockaddr_storage
Date: Wed, 1 Nov 2017 07:49:54 +0100
Message-ID: <20171101064954.GC1585@1wt.eu>
References: <20171031161445.GA140874@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, security@kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171031161445.GA140874@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 31, 2017 at 09:14:45AM -0700, Kees Cook wrote:
> diff --git a/net/socket.c b/net/socket.c
> index c729625eb5d3..34183f4fbdf8 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -2188,6 +2188,7 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
>  	struct sockaddr __user *uaddr;
>  	int __user *uaddr_len = COMPAT_NAMELEN(msg);
>  
> +	memset(&addr, 0, sizeof(addr));
>  	msg_sys->msg_name = &addr;

Isn't this going to cause a performance hit in the fast path ? Just
checking, I have not read the whole code with the patch in its context.

Willy
