From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/7] net: refactor __netif_receive_skb_core
Date: Wed, 15 Apr 2015 12:44:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB1EA6B@AcuExch.aculab.com>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <1428668142-4006-2-git-send-email-pablo@netfilter.org>
 <55282AED.1050306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <55282AED.1050306@gmail.com>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck
> Sent: 10 April 2015 20:56
> On 04/10/2015 05:15 AM, Pablo Neira Ayuso wrote:
> > +another_round:
> > +	ret = __netif_receive_skb_ingress(skb, pfmemalloc, orig_dev);
> > +	switch (ret) {
> > +	case NET_RX_SUCCESS:
> > +	case NET_RX_DROP:
> > +		break;
> > +	case __NET_RX_ANOTHER_ROUND:
> > +		goto another_round;
> > +	}
> >  	rcu_read_unlock();
> > +
> >  	return ret;
> >  }
> >
> >
> 
> Couldn't this just be done as a do while?  It would probably be easier
> to read and there wouldn't be any need for the another_round label anymore.

Or an infinite loop with a break at the bottom, as in:
	for (;;) {
		switch (...) {
		case again:
			continue;
		default:
			break;
		}
		break;
	}

	David

			
