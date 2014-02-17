From: "Kretschmer, Mathias" <mathias.kretschmer-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org>
Subject: RE: [net-next v2 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon, 17 Feb 2014 17:34:34 +0000
Message-ID: <D53252F45158EF44B1DF124FDC9AF2A35AD9E12C@FEYNMAN.fokus.fraunhofer.de>
References: <1392656174-14791-1-git-send-email-sw@simonwunderlich.de>
 <1392656174-14791-4-git-send-email-sw@simonwunderlich.de>
 <5302474B.6090609@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5302474B.6090609-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> It seem eh->h_proto should be the same as skb->protocol, right? So why not
> add these case statements to the switch below?

Thought so, as well. But it seems that skb->protocol is not properly set when the packet originates from a packet socket.
And in our case we cannot set it to a fixed etherType in the bind() call since we use three different etherTypes on the same socket.

Cheers,

Mathias
 
> Regards,
> Arend
> 
> > +		case htons(ETH_P_MPLS_UC):
> > +		case htons(ETH_P_MPLS_MC):
> > +			/* MPLS */
> > +			mpls = skb_header_pointer(skb, sizeof(*eh),
> > +						  sizeof(*mpls),&mpls_tmp);
> > +			if (!mpls)
> > +				break;
> > +
> > +			return (ntohl(mpls->entry)&  MPLS_LS_TC_MASK)
> > +				>>  MPLS_LS_TC_SHIFT;
> > +		case htons(ETH_P_80221):
> > +			/* 802.21 is always network control traffic */
> > +			return 7;
> > +		default:
> > +			break;
> > +		}
> > +	}
> > +
> >   	switch (skb->protocol) {
> >   	case htons(ETH_P_IP):
> >   		dscp = ipv4_get_dsfield(ip_hdr(skb))&  0xfc;

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
