From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/6] net: skbuff: don't use union for napi_id
 and sender_cpu
Date: Thu, 31 Mar 2016 19:55:25 -0700
Message-ID: <1459479325.6473.260.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
	 <1459403439-6011-2-git-send-email-jasowang@redhat.com>
	 <1459420341.6473.225.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FDD94E.8090908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56FDD94E.8090908@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-04-01 at 10:13 +0800, Jason Wang wrote:


> 
> The problem is we want to support busy polling for tun. This needs
> napi_id to be passed to tun socket by sk_mark_napi_id() during
> tun_net_xmit(). But before reaching this, XPS will set sender_cpu will
> make us can't see correct napi_id.
> 

Looks like napi_id should have precedence then ?

Only forwarding should allow the field to be cleared to allow XPS to do
its job.

Maybe skb_sender_cpu_clear() was removed too early (commit
64d4e3431e686dc37ce388ba531c4c4e866fb141)

Look, it is 8pm here, I am pretty sure a solution can be found,
but I am also need to take a break, I started at 3am today...
