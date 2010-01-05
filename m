From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC 0/9] snet: Security for NETwork syscalls
Date: Tue, 05 Jan 2010 17:20:55 +0900
Message-ID: <201001050820.o058Kuwx087793@www262.sakura.ne.jp>
References: <1262437456-24476-1-git-send-email-sam@synack.fr> <1262537872.10218.27.camel@bigi> <m2r5q5nhbc.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, kaber@trash.net,
	zbr@ioremap.net, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca
To: sam@synack.fr
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m2r5q5nhbc.fsf@ssh.synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samir Bellabes wrote:
> I'm currently testing security_sock_rcv_skb() hook - which is inside
> sk_filter() - to get skbuffs when then are arriving, and so trying to
> push the buffer to userspace. In case this is not userfull, userspace
> is able to use the NFQUEUE of netfilter to get skbuff, and deal
> with incoming datas.

Pushing buffer to userspace and wait for userspace's decision will sleep.
sk_filter() which calls security_sock_rcv_skb() hook is called from
(e.g.) tcp_v6_do_rcv() and comment of tcp_v6_do_rcv() says that
"The socket must have it's spinlock held when we get here." 
Also, comment of rxrpc_queue_rcv_skb() says that
"the caller must hold a lock on call->lock".
I think it is not permitted to do sleeping operation inside
security_sock_rcv_skb().
