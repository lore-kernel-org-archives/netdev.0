From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] can: use sock_efree instead of own destructor
Date: Tue, 10 Mar 2015 07:36:25 -0700
Message-ID: <1425998185.8261.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425959300-27132-1-git-send-email-fw@strlen.de>
	 <54FE8BB0.9050508@hartkopp.net>
	 <1425990143.8261.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54FEF355.305@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	mkl@pengutronix.de,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <54FEF355.305@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-10 at 14:36 +0100, Oliver Hartkopp wrote:
> Yes - in connection with sock_rfree() for the read buffer destructur and
> sock_wfree() for the write buffer it can make sense to name a function
> sock_efree() as an unassigned destructor - which does not fiddle with rmem nor
> wmen.
> 
> But both sock_efree() and sock_edemux() lack some comment - especially when it
> makes sense to use them from non-INET contexts which Florian suggested.
> 
> Maybe Alexander can send a patch which adds a comment, as I don't know if I
> would find the best words for it.

Please do not top post on netdev.

If you cannot find best words for it, maybe a comment would not be
useful : Very often, best comments are added by people that had problems
to understand the code ;)

I do not trust comments, I prefer using "git grep" or tools like that to
check call sites.

In this particular case this becomes clear, while being concise.

# git grep -n sock_efree
include/net/sock.h:1526:void sock_efree(struct sk_buff *skb);
include/net/sock.h:1530:#define sock_edemux(skb) sock_efree(skb)
net/core/skbuff.c:3625: clone->destructor = sock_efree;
net/core/sock.c:1658:void sock_efree(struct sk_buff *skb)
net/core/sock.c:1662:EXPORT_SYMBOL(sock_efree);
net/ipv4/udp.c:1992:    skb->destructor = sock_efree;



