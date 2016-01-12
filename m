From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [OOPS] In __netif_receive_skb_core
Date: Tue, 12 Jan 2016 06:19:37 -0800
Message-ID: <1452608377.1223.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <568EA671.7000502@gmail.com> <56929985.3020502@gmail.com>
	 <1452457610.16445.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5694188F.80907@gmail.com>
	 <CAO7SqHA9dNUDG+pYJoQvipE_ErM4Bgo0_o9er_OLxZLDgNVJ8Q@mail.gmail.com>
	 <56944DFA.4050002@gmail.com>
	 <1452560786.1223.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAO7SqHC+fTCyNd8ukSH4tJ1qPvAYzMGSfhrzXmMn0NLve6NTQA@mail.gmail.com>
	 <1452565288.1223.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1452565515.1223.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5694A840.8030900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Salam Noureddine <noureddine@arista.com>,
	"David S. Miller" <davem@davemloft.net>,
	Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sebastian Reichel <sre@kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5694A840.8030900@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-01-12 at 09:16 +0200, Ivaylo Dimitrov wrote:
> 
> On 12.01.2016 04:25, Eric Dumazet wrote:

> >
> > OK please try this fix :
> >
> > diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> > index 10d42f3220ab..f925753668a7 100644
> > --- a/net/phonet/af_phonet.c
> > +++ b/net/phonet/af_phonet.c
> > @@ -377,6 +377,10 @@ static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
> >   	struct sockaddr_pn sa;
> >   	u16 len;
> >
> > +	skb = skb_share_check(skb, GFP_ATOMIC);
> > +	if (!skb)
> > +		return NET_RX_DROP;
> > +
> >   	/* check we have at least a full Phonet header */
> >   	if (!pskb_pull(skb, sizeof(struct phonethdr)))
> >   		goto out;
> >
> >
> 
> That one fixes the oops, though I wonder if your previous patch is 
> needed (I reverted it before testing the current). Unfortunately I don't 
> have SIM card around to test GPRS connection with, will do it as soon as 
> I find one and will report.

Well, this bug in phonet_rcv() is rather obvious, I have no idea why
nobody got crashes or corruptions before today.

I'll send a formal patch.

Thanks for your help !
