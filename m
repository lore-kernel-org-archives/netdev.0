From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: invalid socket structure with ip_early_demux
Date: Fri, 01 Feb 2013 18:25:17 -0800
Message-ID: <1359771917.30177.52.camel@edumazet-glaptop>
References: <510C752F.5010102@codeaurora.org>
	 <1359771370.30177.50.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-arm-msm@vger.kernel.org
To: Steve Muckle <smuckle@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1359771370.30177.50.camel@edumazet-glaptop>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-02-01 at 18:16 -0800, Eric Dumazet wrote:

> skb->sk might be a TIMEWAIT socket.
> 
> Therefore, you cant blindly use skb->sk->sk_socket
> 

A fix would be to add after :

sk = skb->sk;

the following code :

if (sk && sk->sk_state == TCP_TIME_WAIT)
	sk = NULL;
