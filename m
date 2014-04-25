From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: guard against coalescing packets from buggy
 network drivers
Date: Fri, 25 Apr 2014 09:49:35 -0700
Message-ID: <1398444575.29914.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <535A78ED.3020309@secomea.com>
	 <1398440595.29914.77.camel@edumazet-glaptop2.roam.corp.google.com>
	 <535A86F3.5010602@secomea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Svenning =?ISO-8859-1?Q?S=F8rensen?= <sss@secomea.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <535A86F3.5010602@secomea.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-04-25 at 18:01 +0200, Svenning S=C3=B8rensen wrote:

> You are right, of course, there are more effective ways to catch bugg=
y=20
> drivers.
> But they will probably also be much more expensive.
> This one is very cheap, being in a relatively cold path, especially=20
> compared to the memcpy in the same path.

It seems you missed the recent tipc thread then.

They are many ways this code path can be abused, your patch only takes
care of one case.

In tipc case, they added skb to shinfo->frag_list without changing
skb->data_len.

So skb_tailroom(to) was not returning 0 as it should.

The invariant should be more strict.

BUG_ON(to->data + to->len !=3D skb_tail_pointer(to));

I still think a BUG() to catch this is better.

There is no guarantee the developer/user will catch a WARN(),
the bug could sit there a long time.

I have no pity for serious bugs like that.

Since you spot buggy drivers, please provide their fixes or at least
name them so that we can take care of them.

Thanks
