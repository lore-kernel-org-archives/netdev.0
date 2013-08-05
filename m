From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/ipv4: fix the conditions of entering
 TCP_CA_Disorder state
Date: Mon, 05 Aug 2013 11:16:47 -0700
Message-ID: <1375726607.4457.43.camel@edumazet-glaptop>
References: <1375749951-11230-1-git-send-email-yp.fangdong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dong Fang <yp.fangdong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375749951-11230-1-git-send-email-yp.fangdong@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-08-05 at 20:45 -0400, Dong Fang wrote:
> if have some packets loss by network, the kernel can't reach here, we can see
> the tcp_time_to_recover() function:
> 
> static bool tcp_time_to_recover(struct sock *sk, int flag)
> {
> 	struct tcp_sock *tp = tcp_sk(sk);
> 	__u32 packets_out;
> 
> 	/* Trick#1: The loss is proven. */
> 	if (tp->lost_out)
> 		return true;
> 	//...
> }
> 
> when it return true, the following condition will be failed:
> 
> //...
> if (!tcp_time_to_recover(sk, flag)) {
> 	tcp_try_to_open(sk, flag, prior_unsacked);
> 	return;
> }
> //...
> 

I honestly do not understand this changelog, and how it is related to
the patch.

Also its not 'net/ipv4:' issue but 'tcp:' one


Could you please explain the issue again ?

Thanks !
