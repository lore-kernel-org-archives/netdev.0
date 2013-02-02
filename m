From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: invalid socket structure with ip_early_demux
Date: Fri, 01 Feb 2013 18:34:16 -0800
Message-ID: <1359772456.30177.55.camel@edumazet-glaptop>
References: <510C752F.5010102@codeaurora.org>
	  <1359771370.30177.50.camel@edumazet-glaptop>
	 <1359771917.30177.52.camel@edumazet-glaptop>
	 <510C79A3.1020607@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-arm-msm@vger.kernel.org
To: Steve Muckle <smuckle@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <510C79A3.1020607@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-02-01 at 18:27 -0800, Steve Muckle wrote:
> On 02/01/13 18:25, Eric Dumazet wrote:
> > A fix would be to add after :
> > 
> > sk = skb->sk;
> > 
> > the following code :
> > 
> > if (sk && sk->sk_state == TCP_TIME_WAIT)
> > 	sk = NULL;
> 
> Thanks. I assumed the xt_qtaguid code was ok because xt_owner does a
> similar thing - does that also need this fix?
> 

I believe xt_owner only is valid on the OUT path
(LOCAL_OUT and POST_ROUTING), so it shouldnt be an issue.

I fixed netfilter modules in 

commit 0626af3139572610b56376580d11eb65d45d9dd7
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Sep 4 07:49:03 2012 +0000

    netfilter: take care of timewait sockets
    
    Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
    full blown socket.
    
    Since (41063e9 ipv4: Early TCP socket demux), we can have skb->sk
    pointing to a timewait socket.
    
    Same fix is needed in nfnetlink_log.
    
    Diagnosed-by: Florian Westphal <fw@strlen.de>
    Reported-by: Sami Farin <hvtaifwkbgefbaei@gmail.com>
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
