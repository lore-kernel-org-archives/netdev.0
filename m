From: Patrick McHardy <kaber@trash.net>
Subject: Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Tue, 17 Feb 2009 10:03:57 +0100
Message-ID: <499A7D7D.1090607@trash.net>
References: <20090216232016.GA4803@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Karl Hiramoto <karl@hiramoto.org>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20090216232016.GA4803@ami.dom.local>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> Very nice debugging, but I think your patch doesn't look like enough:
> 1) it skips copy for cloned skbs,
> 2) this skb_cow_head() is needed anyway, sometimes.
> So the real bug should be found in skb_cow_head() or elsewhere.
> 
> I attach here 2 patches for testing:
> 1) skb->mac_header update: it looks like needed, but I don't know if
>    it matters here,
> 2) an extention of your patch but with pskb_expand_head() called for
>    one to one copy.
> 
> BTW, if it's not a big problem it would be nice to try this e.g. on
> 2.6.29-rc5.

The first patch looks fine. As for the second one, I would like
to understand why we're seing these packets. The VLAN driver uses
the original headroom plus the space it needs itself, which suggests
that the underlying driver specifies an incorrect headroom.
The driver doesn't appear to be part of the mainline kernel though.

