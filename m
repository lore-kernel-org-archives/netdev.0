From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Sun, 27 Dec 2009 10:20:10 +0900
Message-ID: <200912271020.III12990.JSHOOQOMtFLFFV@I-love.SAKURA.ne.jp>
References: <20091227010441.GA12077@heat>
	<20091227010650.GA12190@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: michael@laptop.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091227010650.GA12190@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone wrote:
> +int disablenetwork_security_socket_sendmsg(struct socket * sock,
> +					   struct msghdr * msg, int size)
> +{
> +	if (sock->sk->sk_family != PF_UNIX &&
> +		current->network &&
> +		(msg->msg_name != NULL || msg->msg_namelen != 0))
> +		return -EPERM;
> +	return 0;
> +}

I think we should accept msg->msg_name != NULL || msg->msg_namelen != 0
if the socket is connection oriented protocols (e.g. TCP).

struct sockaddr_in addr = { ... };
int fd = socket(PF_INET, SOCK_STREAM, 0);
connect(fd, (struct sockadr *) &addr, sizeof(addr));
prctl( ... );
sendmsg(fd, (struct sockadr *) &addr, sizeof(addr));
