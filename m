From: Ian Campbell <Ian.Campbell-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>
Subject: Re: [PATCH 08/13] net: convert drivers to paged frag API.
Date: Fri, 22 Jul 2011 15:16:04 +0100
Message-ID: <1311344164.12772.78.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
	 <1311340653-19336-8-git-send-email-ian.campbell@citrix.com>
	 <20110722.071217.607687554920673786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Chas Williams <chas-vT06rRrALxcmhCb6mdbn6A@public.gmane.org>,
	<linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110722.071217.607687554920673786.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-22 at 15:12 +0100, David Miller wrote:
> From: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> Date: Fri, 22 Jul 2011 14:17:28 +0100
> 
> > -				put_dma(tx->index,eni_dev->dma,&j,(unsigned long)
> > -				    skb_shinfo(skb)->frags[i].page + skb_shinfo(skb)->frags[i].page_offset,
> > +				put_dma(tx->index,eni_dev->dma,&j,
> > +				    (unsigned long)skb_frag_address(&skb_shinfo(skb)->frags[i]),
> 
> This is not an equivalent transformation.
> 
> skb_frag_address() does a page_address() on the frag page, but that is
> not what the code was doing here previously.
> 
> It's possible the code was buggy, but you can't do a fix like that
> amidst what is supposed to be a semantically NOP transformation.

Ouch, you are absolutely right, I didn't spot that, sorry.

The original code does look pretty bogus though, indexing off a struct
page * like that -- CC'ing the ATM maintainer + list.

Ian.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
