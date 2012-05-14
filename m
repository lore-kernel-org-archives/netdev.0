From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 17:24:39 +0200
Message-ID: <1337009079.8512.535.camel@edumazet-glaptop>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com>
	 <20120514144052.GD12992@1984>
	 <alpine.LNX.2.01.1205141702110.11548@frira.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	dan.carpenter@oracle.com, hans@schillstrom.com
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1205141702110.11548@frira.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-05-14 at 17:05 +0200, Jan Engelhardt wrote:
> On Monday 2012-05-14 16:40, Pablo Neira Ayuso wrote:
> 
> >> -		if (t->uports.p16.dst < t->uports.p16.src)
> >> +		if (ntohs(t->uports.p16.dst) < ntohs(t->uports.p16.src))
> >
> >Do we really need this to make sparse happy?
> 
> You need it to make *maths* happy.
> 
> Consider
> 
> 	384 < 65407
> 
> but
> 
> 	    ntohs(384) > ntohs(65407)
> 	<=> 32769 > 32767
> --

Doesnt matter at all in this context.

Take a look at 

void __skb_get_rxhash(struct sk_buff *skb)

if ((__force u16)keys.port16[1] < (__force u16)keys.port16[0])
	swap(...)




