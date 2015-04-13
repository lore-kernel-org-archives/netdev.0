From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] [PATCH RFC] tcp: Allow sk_wmem_alloc to exceed
 sysctl_tcp_limit_output_bytes
Date: Mon, 13 Apr 2015 07:05:25 -0700
Message-ID: <1428933925.3834.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427388414-31077-1-git-send-email-jonathan.davies@citrix.com>
	 <1427390070.25985.145.camel@edumazet-glaptop2.roam.corp.google.com>
	 <551555E3.80205@citrix.com> <552BC899.8090300@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Davies <jonathan.davies@citrix.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>,
	xen-devel@lists.xenproject.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Patrick McHardy <kaber@trash.net>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35219 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbDMOF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:05:27 -0400
Received: by pabtp1 with SMTP id tp1so103130594pab.2
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:05:26 -0700 (PDT)
In-Reply-To: <552BC899.8090300@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-04-13 at 14:46 +0100, David Vrabel wrote:

> > And the proof-of-concept patch for idea (b) I used was:
> > 
> > @@ -552,6 +552,8 @@ static int xennet_start_xmit(struct sk_buff *skb,
> > struct net_device *dev)
> >              goto drop;
> >      }
> > 
> > +    skb_orphan(skb);
> > +
> >      page = virt_to_page(skb->data);
> >      offset = offset_in_page(skb->data);
> >      len = skb_headlen(skb);
> 
> No. This a bunch of allocations and  a full memcpy of all the frags.

skb_orphan() does nothing like that.

But the main concern here is it basically breaks back pressure.

And you do not want this, unless there is no other choice.
