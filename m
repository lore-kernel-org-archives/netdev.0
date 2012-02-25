From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/3] netlink: add netlink_dump_control structure for
 netlink_dump_start()
Date: Sat, 25 Feb 2012 02:12:22 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1202250210240.17151@frira.zrqbmnf.qr>
References: <1330129817-28199-1-git-send-email-pablo@netfilter.org> <1330129817-28199-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	davem@davemloft.net
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1330129817-28199-2-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 2012-02-25 01:30, pablo@netfilter.org wrote:

>From: Pablo Neira Ayuso <pablo@netfilter.org>
>
>Davem considers that the argument list of this interface is getting
>out of control. This patch tries to address this issue following
>his proposal:
>
>struct netlink_dump_control c = { .dump = dump, .done = done, ... };
>
>netlink_dump_start(..., &c);

What about adding skb and nlh into c as well? After all, skb
is not nearly as much {used directly} as it is in Xtables.

>+		{
>+			struct netlink_dump_control c = {
>+				.dump = link->dump,
>+				.done = link->done,
>+			};
>+			return netlink_dump_start(crypto_nlsk, skb, nlh, &c);
>+		}

You can also use

		return netlink_dump_start(crypto_nlsk, skb,
		       &(const struct netlink_dump_control)
		       {.dump = link->dump, .done = link->done}));
