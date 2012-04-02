From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: check the length of the data before dereferencing
 it
Date: Mon, 02 Apr 2012 05:53:17 +0200
Message-ID: <1333338797.2325.6610.camel@edumazet-glaptop>
References: <1333336250-4110-1-git-send-email-xiaosuo@gmail.com>
	 <1333336773.2325.6531.camel@edumazet-glaptop>
	 <20120401.232942.1829187970291547571.davem@davemloft.net>
	 <CABa6K_HfWckb=sv7oQatv2ZJm3EKJE0mutQQ-OiddXiR6E7eHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CABa6K_HfWckb=sv7oQatv2ZJm3EKJE0mutQQ-OiddXiR6E7eHg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-02 at 11:45 +0800, Changli Gao wrote:

> Thinking about a malformed tcp segment, which has no data but silly
> options, and whose last byte is neither TCPOPT_EOL or TCPOPT_NOP, we
> will try to dereference one byte over the boundary when parsing the
> options. I know we have skb_shared_info at the end and it won't cause
> any crash, but should we rely on this fact?
> 

No we cant rely on this, kmemcheck might barf on us.

Your patch (and the netfilter one) is fine.


