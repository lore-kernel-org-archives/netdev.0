From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 18:09:16 +0200
Message-ID: <201205141809.18174.hans.schillstrom@ericsson.com>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com> <alpine.LNX.2.01.1205141702110.11548@frira.vanv.qr> <1337009079.8512.535.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@inai.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1337009079.8512.535.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 14 May 2012 17:24:39 Eric Dumazet wrote:
> On Mon, 2012-05-14 at 17:05 +0200, Jan Engelhardt wrote:
> > On Monday 2012-05-14 16:40, Pablo Neira Ayuso wrote:
> > 
> > >> -		if (t->uports.p16.dst < t->uports.p16.src)
> > >> +		if (ntohs(t->uports.p16.dst) < ntohs(t->uports.p16.src))
> > >
> > >Do we really need this to make sparse happy?
> > 
> > You need it to make *maths* happy.
> > 
> > Consider
> > 
> > 	384 < 65407
> > 
> > but
> > 
> > 	    ntohs(384) > ntohs(65407)
> > 	<=> 32769 > 32767
> > --
> 
> Doesnt matter at all in this context.

This context can contain both le & be machines,
so at least in hmark it make sense

> Take a look at 
> 
> void __skb_get_rxhash(struct sk_buff *skb)
> 
> if ((__force u16)keys.port16[1] < (__force u16)keys.port16[0])
> 	swap(...)
> 
> 



-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
