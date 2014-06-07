From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: [PATCH] ipip, sit: fix ipv4_{update_pmtu,redirect} calls
Date: Sat, 7 Jun 2014 21:36:35 +0400
Message-ID: <20140607213635.490493e5846e3c81704de67d@qrator.net>
References: <20140606231921.2ff39106ac54216fd9170fae@qrator.net>
	<CAHA+R7NUVPz47AKCTk7nYBkZXK=93vJOO8f6FTkyU0UkU6Q30Q@mail.gmail.com>
	<20140607195412.94b079a97a6e1452e539037f@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dmitry Kozlov <xeb@mail.ru>, Cong Wang <cwang@twopensource.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	trivial@kernel.org
To: Dmitry Popov <ixaphire@qrator.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140607195412.94b079a97a6e1452e539037f@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 7 Jun 2014 19:54:12 +0400
Dmitry Popov <ixaphire@qrator.net> wrote:

> 3) gre:
> ipgre is a framework for subprotos which doesn't work with tunnel devices by
> itself (see net/ipv4/gre_demux.c:gre_cisco_err). Although it uses 
> skb->dev->ifindex for ipv4_{update_pmtu,redirect} which might be wrong for hosts
> with asymmetric routing, this is not a big deal, because tunnels bound to device 
> will not work with asymmetric routing anyway. So I think it is okay.

Actually, yes, it may not work in case of unbound tunnel and asymmetric routing,
but we'll need to put icmp redirects/frag_needed handling inside 
gre_cisco_protocol->err_handler then, I am not sure if it's worth it.
