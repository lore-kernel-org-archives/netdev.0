From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2] ip_tunnel: disable preemption when updating per-cpu tstats
Date: Mon, 16 Nov 2015 20:33:42 +0100
Message-ID: <CAHmME9oQuiHfZmW-c0VN9ivQLjC0nPuuprv7-ryS+AqFvAfXMg@mail.gmail.com>
References: <1447342212-5543-1-git-send-email-Jason@zx2c4.com>
	<1447346158-19257-1-git-send-email-Jason@zx2c4.com>
	<20151116.141737.420755936779587001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, tgraf@suug.ch,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151116.141737.420755936779587001.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 16, 2015 at 8:17 PM, David Miller <davem@davemloft.net> wrote:
> So another fix could have been to do local_bh_disable() in the
> udp_tunnel6_xmit_skb() helper.

This would have fixed one problem, but everywhere
udp_tunnel_xmit_skb() (4, not 6) is called, iptunnel_xmit_stats is
called right after it, so there would have to be a modicum of patches
for all of these places too.

By the way, there's something else I noticed about this in dealing
with these functions: the return value of udp_tunnel_xmit_skb is
different from that of udp_tunnel6_xmit_skb. Nobody is using them
incorrectly, so far as I can see, but it is confusing that they return
different things. I had started to clean this up and send a patch, but
it got a bit invasive in drivers I shouldn't really touch. But if
somebody with a bit more top-down command of things wants to poke at
this, it's a low hanging fruit as far as I can see.

>
> Thanks again.

My pleasure.
