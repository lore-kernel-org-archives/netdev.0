From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Handle shared SKBs in VLAN receive code
Date: Sat, 11 Oct 2003 12:54:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011125426.542e47f7.davem@redhat.com>
References: <3F87430D.2040000@tpack.net>
	<3F87464B.1020908@candelatech.com>
	<3F874A30.6010700@tpack.net>
	<3F885418.3090407@candelatech.com>
	<20031011120339.0da631e6.davem@redhat.com>
	<3F88602B.7020603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, tommy.christensen@tpack.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F88602B.7020603@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Oct 2003 12:55:23 -0700
Ben Greear <greearb@candelatech.com> wrote:

> I have read the sk_buf.h file repeatedly trying to get this all straight
> in my head, and I think I'm still missing things.  Is there any other
> documentation around that describes in detail exactly the things you must
> do to handle shared skbs in all contexts?

No there isn't, sorry.

If you just want to read the IP address in a packet, or anything else
in general you have two options:

1) if (pskb_may_pull(skb, len))
	goto drop;

   After this call, it is guarenteed you may look at
   the all bytes up to 'len' from the start of the SKB
   using skb->data et al.

2) Use skb_peek_bits().
